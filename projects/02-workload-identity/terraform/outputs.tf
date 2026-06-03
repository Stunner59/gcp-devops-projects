output "workload_identity_provider" {
  description = "Workload Identity Provider resource name — paste this in GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "service_account_email" {
  description = "Service Account email — paste this in GitHub Actions"
  value       = google_service_account.github_actions_sa.email
}
