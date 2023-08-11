output "network_id" {
  value = google_compute_network.ter_network.id
}

output "subnet_id" {
  value = google_compute_subnetwork.ter_subnet.id
}