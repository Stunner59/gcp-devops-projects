output "vpc_name" {
  value = module.vpc.vpc_name
}

output "public_subnet" {
  value = module.vpc.public_subnet
}

output "private_subnet" {
  value = module.vpc.private_subnet
}
