resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "google_project" "project" {
  name                = var.project_name
  project_id          = random_id.id.hex
  billing_account     = var.billing_account
  auto_create_network = false
}

resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "iap.googleapis.com"
  ])

  service            = each.key
  project            = google_project.project.project_id
  disable_on_destroy = false
}

resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"
  
  depends_on = [google_project.project]
    
}

