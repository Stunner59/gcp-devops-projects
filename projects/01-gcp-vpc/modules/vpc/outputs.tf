output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "public_subnet" {
  value = google_compute_subnetwork.public.name
}

output "private_subnet" {
  value = google_compute_subnetwork.private.name
}
