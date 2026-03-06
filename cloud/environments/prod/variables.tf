variable "aws_region" {
  description = "Regió AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nom de l'entorn"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloc CIDR per la VPC"
  type        = string
}

variable "public_subnets" {
  description = "Subxarxes Públiques"
  type        = list(string)
}

variable "private_subnets" {
  description = "Subxarxes Privades"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zones de Disponibilitat"
  type        = list(string)
}

variable "instance_type" {
  description = "Tipus d'instància"
  type        = string
}

variable "db_password" {
  description = "Contrasenya per la base de dades"
  type        = string
  sensitive   = true
}
