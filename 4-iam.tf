# Authorization is based on a defult service account
# IAM & Admin: give user@test.com access rights: Compute OS Login
# IAM & Admin: assign user@test.com to Compute Default Service Account
# Security/Identity-Aware Proxy: assign user@test.com access rights for IAP-Secured Tunnel User
#
# Usage: gcloud beta compute ssh --zone "europe-central2-a" "bastion-host"  --tunnel-through-iap --project "sg-bastion-b1eb3ce7"
#


variable "bastion_users" {
  type    = set(string)
  default = []

}
resource "google_project_iam_member" "bh-os-login" {
  project  = google_project.project.project_id
  role     = "roles/compute.osLogin"
  for_each = var.bastion_users

  member = "user:${each.value}"
}

# resource "google_project_iam_member" "project" {
#   project  = google_project.project.project_id
#   role     = "roles/compute.instanceAdmin.v1"
#   for_each = var.bastion_users

#   member = "user:${each.value}"
# }


data "google_compute_default_service_account" "default" {
  project = google_project.project.project_id

}
resource "google_service_account_iam_member" "default_sa" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"

  for_each = var.bastion_users

  member = "user:${each.value}"
}


resource "google_iap_tunnel_iam_member" "member" {
  project  = google_project.project.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  for_each = var.bastion_users

  member = "user:${each.value}"

  depends_on = [time_sleep.wait_120_seconds]

}

output "list_of_entitled_users" {
    value = [for i in var.bastion_users : i ]

}

output "running_instruction" {
  
  value = <<EOT
    cloud beta compute ssh --zone "${local.region-a-zone-a}" "${google_compute_instance.bastion_host.name}" --tunnel-through-iap --project "${google_project.project.project_id}" 
EOT


}