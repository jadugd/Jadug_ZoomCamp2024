-- Homework 3
-- Load External Table from GCS
-- Parquet File uploaded to GCS Using Mage Pipelines
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp2024-411908.homework_3.external_green_taxi_2022`
OPTIONS (
  format = 'parquet',
  uris = ['gs://mage-zoomcamp-jadugd/homework_3/green_taxi_2022.parquet']
);

-- Check data
SELECT * FROM `zoomcamp2024-411908.homework_3.external_green_taxi_2022`;

-- No. 1 Count Records
SELECT COUNT(*) FROM `zoomcamp2024-411908.homework_3.external_green_taxi_2022`; --840402

-- Create Materialized Table for green_taxi table
CREATE OR REPLACE TABLE `zoomcamp2024-411908.homework_3.materialized_green_taxi_2022`
AS
SELECT VendorID, TIMESTAMP_MICROS(CAST(lpep_pickup_datetime/1000 AS INT)) AS lpep_pickup_datetime, 
TIMESTAMP_MICROS(CAST(lpep_dropoff_datetime/1000 AS INT)) AS lpep_dropoff_datetime, store_and_fwd_flag, RatecodeID, PULocationID, DOLocationID, passenger_count, trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount, ehail_fee,improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge
FROM `zoomcamp2024-411908.homework_3.external_green_taxi_2022`;

-- No.2 Count Distinct PULocationID for Both Tables

-- External Tables Query
-- Takes 0 B When Processing
SELECT COUNT(DISTINCT PULocationID) 
FROM `zoomcamp2024-411908.homework_3.external_green_taxi_2022`;

-- Materialized Table Query
-- Takes 6.41MB when run
SELECT COUNT(DISTINCT PULocationID) 
FROM `zoomcamp2024-411908.homework_3.materialized_green_taxi_2022`;

-- No.3 Count 0 fare_amount records
SELECT COUNT(*) 
FROM `zoomcamp2024-411908.homework_3.external_green_taxi_2022`
WHERE fare_amount = 0; --1622

-- No.4
-- Query Before Clustering and Partitioning
-- Takes 114.11 MB When Running
SELECT * 
FROM `zoomcamp2024-411908.homework_3.materialized_green_taxi_2022`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-01-01' AND '2022-07-31'
ORDER BY PULocationID;

-- Try to Cluster by Date and Partition By PULocationID
CREATE OR REPLACE TABLE `zoomcamp2024-411908.homework_3.green_taxi_2022_clustering_partitioned`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PULocationID AS
SELECT * FROM `zoomcamp2024-411908.homework_3.materialized_green_taxi_2022`;

-- Check Partitioned and Clustered Cost
-- Proceed 67.94MB When running
SELECT * 
FROM `zoomcamp2024-411908.homework_3.green_taxi_2022_clustering_partitioned`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-01-01' AND '2022-07-31'
ORDER BY PULocationID;

-- No. 5

-- Query on Materialized Table
-- Cost 12.82 MB When Processing
SELECT DISTINCT PULocationID
FROM `zoomcamp2024-411908.homework_3.materialized_green_taxi_2022`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

-- Query on Partitioned and Clustered Table
-- Cost 1.12 MB When Processing
SELECT DISTINCT PULocationID
FROM `zoomcamp2024-411908.homework_3.green_taxi_2022_clustering_partitioned`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

-- No. 8
-- Cost 0B When running
-- According to BQ Pricing Documentation https://cloud.google.com/bigquery/pricing#table when use count syntax it's access metadata of the table so it already cached and doesn't cost anything
SELECT COUNT(*)
FROM `zoomcamp2024-411908.homework_3.materialized_green_taxi_2022`;