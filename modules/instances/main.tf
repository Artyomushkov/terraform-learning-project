module "vpc" {
  source = "../vpc"
}

resource "google_compute_instance_template" "ter-instance" {
  name         = "ter-instance"
  machine_type = "f1-micro"

  disk {
    boot         = true
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network    = module.vpc.network_id
    subnetwork = module.vpc.subnet_id
    access_config {
    }
  }

  metadata_startup_script = "apt update; apt install -y apache2; echo \"Hello from `hostname`\" > /var/www/html/index.html;"
}

resource "google_compute_health_check" "tcp-health-check" {
  name = "tcp-health-check"

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_instance_group_manager" "ter-group" {
  name = "ter-group"

  base_instance_name = "ter-instance"
  region                     = "us-central1"
  distribution_policy_zones  = ["us-central1-a", "us-central1-b", "us-central1-c"]

  version {
    name              = "web-server"
    instance_template = google_compute_instance_template.ter-instance.self_link
  }

  target_size = 3

  auto_healing_policies {
    health_check      = google_compute_health_check.tcp-health-check.id
    initial_delay_sec = 50
  }

  named_port {
    name = "http-port"
    port = 80
  }
}