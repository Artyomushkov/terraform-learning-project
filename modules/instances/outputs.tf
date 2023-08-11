output "instance_group" {
  value = google_compute_region_instance_group_manager.ter-group.instance_group
}

output "health_checker" {
  value = google_compute_health_check.tcp-health-check.id
}