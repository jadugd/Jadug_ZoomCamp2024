-- create external table for fhv data 2019
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp2024-411908.trips_data_all.external_fhv_tripdata_2019`
OPTIONS (
  format = 'parquet',
  uris = ['gs://hw_bucket_test/fhv/fhv_*.parquet']
);

-- create a materialized table
CREATE OR REPLACE TABLE `zoomcamp2024-411908.trips_data_all.fhv_tripdata`
AS
SELECT 
*
FROM `zoomcamp2024-411908.trips_data_all.external_fhv_tripdata_2019`;