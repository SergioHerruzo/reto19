variable "environment" {
  description = "Aquest és el nom de l'entorn"
  type        = string
}

variable "identifier" {
  description = "Identificador únic per la base de dades"
  type        = string
}

variable "subnet_ids" {
  description = "Llista de subxarxes privades on desplegar la RDS"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Llista de Security Groups per permetre l'accés a la RDS"
  type        = list(string)
}

variable "db_username" {
  description = "Nom d'usuari administrador per defecte de la BD"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contrasenya administradora de la BD"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Emmagatzematge en GB (minim 20 per free tier)"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "Tipus d'instància compatible amb AWS Academy Free Tier"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Motor de base de dades (ex: mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Versió del motor de base de dades"
  type        = string
  default     = "8.0"
}
