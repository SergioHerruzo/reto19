variable "environment" {
  description = "Aquest és el nom de l'entorn (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block per a la VPC"
  type        = string
}

variable "public_subnets" {
  description = "Llista de CIDR blocks per a les subxarxes públiques"
  type        = list(string)
}

variable "private_subnets" {
  description = "Llista de CIDR blocks per a les subxarxes privades"
  type        = list(string)
}

variable "availability_zones" {
  description = "Llista de Availability Zones a utilitzar"
  type        = list(string)
}
