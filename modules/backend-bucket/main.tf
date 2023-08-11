resource "google_storage_bucket" "default" {
  name          = "123123-labproject-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}