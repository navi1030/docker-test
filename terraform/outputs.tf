# outputs.tf
output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}
output "vpc_name" {
  value = google_compute_network.vpc_network.name
}
output "state_bucket_name" {
  value = google_storage_bucket.terraform_state.name
}