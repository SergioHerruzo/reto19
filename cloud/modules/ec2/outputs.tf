output "instance_id" {
  description = "ID de la instància creada"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "IP pública de la instància (si en té)"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "IP privada de la instància"
  value       = aws_instance.this.private_ip
}
