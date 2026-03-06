terraform {
  backend "s3" {
    bucket         = "staging-app-assets-sergio123" # Reemplaçar pel nom real
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true # Disposible des de Terraform 1.7
  }
}
