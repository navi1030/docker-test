provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "gke-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
}

resource "google_container_cluster" "gke_cluster" {
  name               = "gke-cluster"
  location           = var.region
  network            = google_compute_network.vpc_network.self_link
  subnetwork         = google_compute_subnetwork.subnet.self_link
  remove_default_node_pool = true
  initial_node_count = 1

}

resource "google_container_node_pool" "general_node_pool" {
  name       = "general-node-pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = var.region

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  initial_node_count = 3
}

resource "google_container_node_pool" "cpu_intensive_node_pool" {
  name       = "cpu-intensive-node-pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = var.region

  node_config {
    machine_type = "c2-standard-4"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  initial_node_count = 2
}
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "bucket_binding" {
  bucket = google_storage_bucket.terraform_state.name

  role = "roles/owner"

  members = [
    "serviceAccount:${var.terraform_sa_email}"
  ]
}

terraform {
  backend "gcs" {
    bucket  = google_storage_bucket.terraform_state.name
    prefix  = "terraform/state"
  }
}