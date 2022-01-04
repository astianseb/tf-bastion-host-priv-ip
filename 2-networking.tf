################ VPC Demo ##################
resource "google_compute_network" "vpc_demo" {
  name                    = "vpc-demo"
  auto_create_subnetworks = false
  mtu                     = 1460
  project                 = google_project.project.project_id
}

resource "google_compute_subnetwork" "vpc_demo_subnet1" {
  name          = "vpc-demo-subnet1"
  region        = var.region_a
  project       = google_project.project.project_id
  ip_cidr_range = "10.1.1.0/24"
  network       = google_compute_network.vpc_demo.id
}

resource "google_compute_subnetwork" "vpc_demo_subnet2" {
  name          = "vpc-demo-subnet2"
  region        = var.region_b
  project       = google_project.project.project_id
  ip_cidr_range = "10.2.1.0/24"
  network       = google_compute_network.vpc_demo.id
}

resource "google_compute_firewall" "vpc_demo_allow_internal" {
  name      = "vpc-demo-allow-internal"
  project   = google_project.project.project_id
  network   = google_compute_network.vpc_demo.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.vpc_demo_subnet1.ip_cidr_range,
  google_compute_subnetwork.vpc_demo_subnet2.ip_cidr_range]
}

resource "google_compute_firewall" "vpc_demo_allow_iap" {
  name      = "vpc-demo-allow-iap"
  project   = google_project.project.project_id
  network   = google_compute_network.vpc_demo.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }
  source_ranges = ["35.235.240.0/20"]
}
