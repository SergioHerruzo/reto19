terraform {
  backend "s3" {
    bucket         = "dev-app-assets-sergio123" # Reemplaçar pel nom real del bucket que tinguis creat per state
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true # Disposible des de Terraform 1.7
  }
}
