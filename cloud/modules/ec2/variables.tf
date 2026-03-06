variable "environment" {
  description = "Aquest és el nom de l'entorn"
  type        = string
}

variable "instance_type" {
  description = "Tipus d'instància EC2 (ex: t2.micro, t2.small)"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subxarxa on desplegar la instància"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Llista de Security Groups per a la instància"
  type        = list(string)
}

variable "instance_name" {
  description = "Nom per referenciar l'ús de la instància (ex: bastion, web)"
  type        = string
}

variable "ami_id" {
  description = "AMI a utilitzar. Per defecte AWS Linux 2023 si es deixa buit"
  type        = string
  default     = ""
}
