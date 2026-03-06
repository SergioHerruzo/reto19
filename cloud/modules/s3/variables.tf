variable "environment" {
  description = "Nom de l'entorn"
  type        = string
}

variable "bucket_name" {
  description = "Nom del bucket S3 (ha de ser únic globalment)"
  type        = string
}

variable "enable_versioning" {
  description = "Activar versionament dels objectes al bucket"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Permetre esborrar el bucket encara que contingui objectes (útil per laboratoris)"
  type        = bool
  default     = true
}
