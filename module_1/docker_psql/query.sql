-- Join yellow_taxi_trips table with zones table
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	concat(zpu."Borough",' / ',zpu."Zone") as pickup_location,
	CONCAT(zdo."Borough",' / ',zdo."Zone") as dropoff_location
from 
	yellow_taxi_trips t,
	zones zpu,
	zones zdo
where
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
limit 100;

-- join like the first query using join statement
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	concat(zpu."Borough",' / ',zpu."Zone") as pickup_location,
	CONCAT(zdo."Borough",' / ',zdo."Zone") as dropoff_location
from 
	yellow_taxi_trips t JOIN zones zpu 
		ON t."PULocationID" = zpu."LocationID"
	JOIN zones zdo
		ON t."DOLocationID" = zdo."LocationID"
limit 100;

-- check if there's pickup location not existed in zones 
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
from 
	yellow_taxi_trips t 
where
	"PULocationID" NOT IN (select "LocationID" from zones)
limit 100;

-- try to delete one zones, to check the query above
delete from zones where "LocationID" = 142;

-- using left join to show the unavailable location in zones table
select 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	concat(zpu."Borough",' / ',zpu."Zone") as pickup_location,
	CONCAT(zdo."Borough",' / ',zdo."Zone") as dropoff_location
from 
	yellow_taxi_trips t LEFT JOIN zones zpu 
		ON t."PULocationID" = zpu."LocationID"
	JOIN zones zdo
		ON t."DOLocationID" = zdo."LocationID"
limit 100;

-- using cast on dropofftime, group by and order by
select 
	CAST(tpep_dropoff_datetime AS DATE) as "day",
	COUNT(1) as "count",
	MAX(total_amount),
	MAX(passenger_count)
from 
	yellow_taxi_trips t 
group by
	CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "count" DESC;

-- simpflied the group by syntax and multiple order by
select 
	CAST(tpep_dropoff_datetime AS DATE) as "day",
	"DOLocationID",
	COUNT(1) as "count",
	MAX(total_amount),
	MAX(passenger_count)
from 
	yellow_taxi_trips t 
group by
	1, 2
ORDER BY 
	"day" ASC,
	"DOLocationID" ASC;