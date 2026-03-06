provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source             = "../../modules/vpc"
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# Per simplificar en AWS Academy, utilitzem el security group per defecte de la VPC
# o en creem de simples.
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Permet HTTP i SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Permet acces a MySQL des de Web"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "bastion" {
  source                 = "../../modules/ec2"
  environment            = var.environment
  instance_type          = "t2.micro" # O el que estigui mapejat pels vars
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  instance_name          = "bastion"
}

module "web_server" {
  source                 = "../../modules/ec2"
  environment            = var.environment
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  instance_name          = "web"
}

module "rds" {
  source                 = "../../modules/rds"
  environment            = var.environment
  identifier             = "database"
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_password            = var.db_password
}

module "app_bucket" {
  source            = "../../modules/s3"
  environment       = var.environment
  bucket_name       = "${var.environment}-app-assets-sergio123" # Reemplaça per un nom únic globalment
  enable_versioning = true
}
