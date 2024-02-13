-- Query public available table
SELECT station_id, name FROM
    bigquery-public-data.new_york_citibike.citibike_stations
LIMIT 100;

-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp2024-411908.ny_taxi.external_yellow_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://nyc-tl-data/trip data/yellow_tripdata_2019-*.csv', 'gs://nyc-tl-data/trip data/yellow_tripdata_2020-*.csv']
);

-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp2024-411908.nyc_taxi.external_yellow_tripdata`
OPTIONS (
  format = 'parquet',
  uris = ['gs://mage-zoomcamp-jadugd/nyc_taxi_data.parquet']
);

-- Check yello trip data
SELECT * FROM `zoomcamp2024-411908.nyc_taxi.external_yellow_tripdata` limit 10;

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE zoomcamp2024-411908.nyc_taxi.yellow_tripdata_non_partitoned AS
SELECT A.*, TIMESTAMP_MICROS(CAST(A.tpep_pickup_datetime / 1000 AS INT64)) as pickup_datetime, TIMESTAMP_MICROS(CAST(A.tpep_dropoff_datetime / 1000 AS INT64)) as dropoff_datetime  FROM zoomcamp2024-411908.nyc_taxi.external_yellow_tripdata A;

-- preview the data and convert the datetime_pickup
SELECT TIMESTAMP_MICROS(CAST(tpep_pickup_datetime / 1000 AS INT64)) FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_non_partitoned LIMIT 10;

-- Create a partitioned table from external table
CREATE OR REPLACE TABLE zoomcamp2024-411908.nyc_taxi.yellow_tripdata_partitoned
PARTITION BY 
  DATE(pickup_datetime) AS
SELECT * FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_non_partitoned;

-- Impact of partition
-- Scanning 18.99MB of data
SELECT DISTINCT(VendorID)
FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_non_partitoned
WHERE DATE(pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Scanning ~0B of DATA
SELECT DISTINCT(VendorID)
FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_partitoned
WHERE DATE(pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Let's look into the partitons
SELECT table_name, partition_id, total_rows
FROM `nyc_taxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitoned'
ORDER BY total_rows DESC;

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE zoomcamp2024-411908.nyc_taxi.yellow_tripdata_partitoned_clustered
PARTITION BY DATE(pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_non_partitoned;

-- Comparison using clustered and non clustered partitioned table
-- Query scans 18.99MB
SELECT count(*) as trips
FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_partitoned
WHERE DATE(pickup_datetime) BETWEEN '2009-06-01' AND '2021-12-31'
  AND VendorID=1;

-- Query scans ~0B of DATA
SELECT count(*) as trips
FROM zoomcamp2024-411908.nyc_taxi.yellow_tripdata_partitoned_clustered
WHERE DATE(pickup_datetime) BETWEEN '2009-06-01' AND '2021-12-31'
  AND VendorID=1;
