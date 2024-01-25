## Homework Solution

Original link for the homework : [2024_Homework](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/01-docker-terraform/homework.md)

## Question 1. Knowing docker tags

run this docker run help command:

```docker run --help```

the answer is :

`--rm                               Automatically remove the container when it exits`

## Question 2. Understanding docker first run

To run docker with python 3.9 image use this command :

```docker run -it python:3.9```

The -i option ensures that input from the user is passed to the container, while the -t option associates the user's terminal with a terminal within the container.

but it'll be directing you to python window like you type python in terminal.

To set the entrypoint of bash so we can type the command you can additional command when running :

```docker run -it --entrypoint /bin/bash python:3.9```

then you can run `pip list` on the terminal window and it'll give you output like this :

```bash
$ docker run -it --entrypoint /bin/bash python:3.9
root@b2db6ccd7cd7:/# pip listt
ERROR: unknown command "listt" - maybe you meant "list"
root@b2db6ccd7cd7:/# pip list
Package    Version
---------- -------
pip        23.0.1
setuptools 58.1.0
wheel      0.42.0

[notice] A new release of pip is available: 23.0.1 -> 23.3.2
[notice] To update, run: pip install --upgrade pip
root@b2db6ccd7cd7:/# exit
exit
```

So, the wheel version is `0.42.0`

# Prepare Postgres

I started up my postgres database and pgadmin from module 1 course [here](https://github.com/jadugd/Jadug_ZoomCamp2024/blob/main/module_1/docker_psql/docker-compose.yaml) :

```bash
$ cd module_1/docker_psql/
$ docker compose up -d
[+] Running 2/3
 ⠧ Network docker_psql_default         Created                                                                                         0.7s 
 ✔ Container docker_psql-pgadmin-1     Started                                                                                         0.7s 
 ✔ Container docker_psql-pgdatabase-1  Started 
```

Then i use pgcli command to connect to the database :

```bash 
$ pgcli -h localhost -p 5432 -u root -d ny_taxi
```

I use jupyter notebook to ingest data from csv to database [link](https://github.com/jadugd/Jadug_ZoomCamp2024/blob/main/homework/module_1/homework_upload_data.ipynb)

## Question 3. Count records 

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18. 

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the format timestamp (date and hour+min+sec) and not in date.

I use this query to find the answer :

```sql
select 
count(1) 
from green_taxi_trips t
where to_char(t.lpep_pickup_datetime, 'yyyy-mm-dd') = '2019-09-18'
and to_char(t.lpep_dropoff_datetime, 'yyyy-mm-dd') = '2019-09-18';
```
The output from the query above is :

```bash
+-------+
| count |
|-------|
| 15612 |
+-------+
```

## Question 4. Largest trip for each day

Which was the pick up day with the largest trip distance
Use the pick up time for your calculations.

Here's my query attempt to solve the question above :

```sql
select 
 cast(t.lpep_pickup_datetime as DATE) as "day",
 max(t.trip_distance) as "trip_distance"
from green_taxi_trips t
group by "day"
order by 2 desc;
```

The output from query above gonna be like this :

```bash
+------------+---------------+
| day        | trip_distance |
|------------+---------------|
| 2019-09-26 | 341.64        |
| 2019-09-21 | 135.53        |
| 2019-09-16 | 114.3         |
| 2019-09-28 | 89.64         |
+------------+---------------+
```

so, i'm picking `2019-09-26` as an answer

## Question 5. Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

`First we need to filter the pickup time to '2019-09-18'
and then join the green_taxi_trips table to zone table to know the pickup location name. I ordered the total_amount descending and limit them to 3 so i know the top 3 highest total_amount `

Hers's my query attempt :

```sql
select 
	z."Borough",
	SUM(t.total_amount) as "sum_total_amount"
from 
	green_taxi_trips t join taxi_zone z
	ON z."LocationID"=t."PULocationID"
where
	to_char(t.lpep_pickup_datetime, 'yyyy-mm-dd') = '2019-09-18'
GROUP BY 1
HAVING SUM(t.total_amount) > 50000
ORDER BY 2 DESC
LIMIT 3;
```
The query above give output like this :
```bash
+-----------+-------------------+
| Borough   | sum_total_amount  |
|-----------+-------------------|
| Brooklyn  | 96333.24000000082 |
| Manhattan | 92271.29999999981 |
| Queens    | 78671.70999999889 |
+-----------+-------------------+
```
So, i'm picking `"Brooklyn" "Manhattan" "Queens"`


## Question 6. Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`


Here's my attempt solution :

```sql
select
	pu."Zone" as "pickup_zone",
	d."Zone" as "drop_off_zone",
	t.tip_amount
from
	green_taxi_trips t join taxi_zone d
	ON d."LocationID" = t."DOLocationID"
	join taxi_zone pu
	ON pu."LocationID" = t."PULocationID"
where
	pu."Zone" = 'Astoria'
order by tip_amount desc;
```
we need to join the green_taxi_trips table to zone table so we can filter Astoria as the pickup zone, and then select the tip_amount from taxi_trips and ordered them descending so we find the largest tip.

So, here's the output from query above :

```bash
+-------------+-------------------------------------+------------+
| pickup_zone | drop_off_zone                       | tip_amount |
|-------------+-------------------------------------+------------|
| Astoria     | JFK Airport                         | 62.31      |
| Astoria     | Woodside                            | 30.0       |
| Astoria     | Kips Bay                            | 28.0       |
+-------------+-------------------------------------+------------+
```
The drop_off_zone that give largest tip is `JFK Airport`


## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

I already copied the file and put in my homework folder located here : [main.tf](https://github.com/jadugd/Jadug_ZoomCamp2024/blob/main/homework/module_1/terra/main.tf) and [variables.tf](https://github.com/jadugd/Jadug_ZoomCamp2024/blob/main/homework/module_1/terra/variables.tf)

## Question 7. Creating Resources

After updating the main.tf and variable.tf files run:

```
terraform apply
```

Paste the output of this command into the homework submission form.

```bash
$ cd homework/module_1/terra/
$ ls
main.tf  variables.tf
```

Initializing the terraform code :
```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/google versions matching "5.6.0"...
- Installing hashicorp/google v5.6.0...
- Installed hashicorp/google v5.6.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

```

use `terraform plan` command to preview the what the code adds

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.demo_dataset will be created
  ....
  # google_storage_bucket.demo-bucket will be created
  ....
Plan: 2 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
apply" now.
```
and then finnaly use `terraform apply` to apply the changes.

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.demo_dataset will be created
  ...

  # google_storage_bucket.demo-bucket will be created
  ....

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.demo_dataset: Creating...
google_storage_bucket.demo-bucket: Creating...
google_bigquery_dataset.demo_dataset: Creation complete after 1s [id=projects/zoomcamp2024-411908/datasets/homework_dataset]
google_storage_bucket.demo-bucket: Creation complete after 2s [id=terraform-homework-terra-bucket]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

## Closing
That's all thanks for reading 😉, i enjoyed every course materials from DataTalks