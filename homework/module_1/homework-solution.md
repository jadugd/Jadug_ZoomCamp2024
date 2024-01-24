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
SELECT 1
Time: 0.140s
root@localhost:ny_taxi>
```


