resource "google_compute_network" "ter_network" {
  name                    = "ter-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ter_subnet" {
  name          = "ter-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.ter_network.id
}

resource "google_compute_firewall" "ter_http_allow" {
  name = "ter-allow-http"
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  network       = google_compute_network.ter_network.id
  source_ranges = ["0.0.0.0/0"]
}