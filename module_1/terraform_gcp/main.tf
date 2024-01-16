terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.12.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "zoomcamp2024-411321"
  region  = "us-central1"
}

resource "google_storage_bucket" "auto-destroy-bucket" {
  name          = "zoomcamp2024-411321-terra-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1 #in days
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}