output "load_balancer_ip" {
  description = "Access Jenkins at this IP"
  value       = google_compute_global_forwarding_rule.jenkins.ip_address
}

output "jenkins_mig" {
  description = "Managed Instance Group name"
  value       = google_compute_region_instance_group_manager.jenkins.name
}

output "jenkins_sa" {
  description = "Jenkins Service Account"
  value       = google_service_account.jenkins_sa.email
}
