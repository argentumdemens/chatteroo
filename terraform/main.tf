provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "ID of the project where resources will go."
  type        = string
}

variable "region" {
  description = "Region of the Cloud Run service."
  type        = string
}

terraform {
  backend "gcs" {
    bucket = "chatteroo-terraform-state"
    prefix = "terraform/state"
  }
}

resource "google_storage_bucket" "terraform_state_bucket" {
  name          = "chatteroo-terraform-state"
  location      = var.region
  force_destroy = true
  storage_class = "STANDARD"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_cloud_run_service" "chatteroo" {
  name     = "chatteroo"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/chatteroo-docker/chatapp:latest"

        
      }
    }
  }

  traffic {
    percent        = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  service    = google_cloud_run_service.chatteroo.name
  location   = google_cloud_run_service.chatteroo.location
  role       = "roles/run.invoker"
  member     = "allUsers"
}