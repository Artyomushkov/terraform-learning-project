resource "google_compute_security_policy" "policy" {
  name = "my-policy"

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["45.159.74.167"]
      }
    }
    description = "Allow access to specified IPs"
  }

  rule {
    action   = "deny(404)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Deny access to everybody else"
  }
}