terraform {
  backend "gcs" {
    bucket = "123123-labproject-bucket-tfstate"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source = "./modules/instances"
}

module "security-policy" {
  source = "./modules/security-policy"
}

module "backend-bucket" {
  source = "./modules/backend-bucket"
}

resource "google_compute_global_address" "lb-ip" {
  name = "lb-ip"
}

resource "google_compute_global_forwarding_rule" "lb-forwarding-rule" {
  name                  = "lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.lb-http-proxy.id
  ip_address            = google_compute_global_address.lb-ip.id
}

resource "google_compute_target_http_proxy" "lb-http-proxy" {
  name    = "lb-http-proxy"
  url_map = google_compute_url_map.lb-url-map.id
}

resource "google_compute_url_map" "lb-url-map" {
  name            = "lb-url-map"
  default_service = google_compute_backend_service.lb-web-server.id
}

resource "google_compute_backend_service" "lb-web-server" {
  name                  = "lb-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  port_name             = "http-port"
  timeout_sec           = 10
  health_checks         = [module.instances.health_checker]
  security_policy       = module.security-policy.policy_id
  backend {
    group           = module.instances.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


