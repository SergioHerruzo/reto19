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

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.staging_to_dev.id
}
