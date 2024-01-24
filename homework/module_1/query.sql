select 
count(1) 
from green_taxi_trips t
where to_char(t.lpep_pickup_datetime, 'yyyy-mm-dd') = '2019-09-18'
and to_char(t.lpep_dropoff_datetime, 'yyyy-mm-dd') = '2019-09-18';

select 
 cast(t.lpep_pickup_datetime as DATE) as "day",
 max(t.trip_distance) as "trip_distance"
from green_taxi_trips t
group by "day"
order by 2 desc;

select 
	z."Borough",
	SUM(t.total_amount) as "total"
from 
	green_taxi_trips t join taxi_zone z
	ON z."LocationID"=t."PULocationID"
where
	to_char(t.lpep_pickup_datetime, 'yyyy-mm-dd') = '2019-09-18'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


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
	to_char(t.lpep_pickup_datetime, 'dd-mm-yyyy') between '01-09-2019' and '30-09-2018'
and
	pu."Zone" = 'Astoria'
order by tip_amount desc;