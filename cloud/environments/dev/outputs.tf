output "vpc_id" {
  value = module.vpc.vpc_id
}

output "web_public_ip" {
  value = module.web_server.public_ip
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}
