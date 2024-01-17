variable "location" {
  description = "Project Location"
  default = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name Demo"
  default = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name Demo"
  default = "zoomcamp2024-411321-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default = "STANDARD"
}