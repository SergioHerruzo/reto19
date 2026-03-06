provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "Regió AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Contrasenya per defecte per a les bases de dades"
  type        = string
  sensitive   = true
  default     = "P4ssw0rd.academy"
}

# =======================================================
# DEV ENVIRONMENT
# =======================================================
module "vpc_dev" {
  source             = "../modules/vpc"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

resource "aws_security_group" "web_sg_dev" {
  name        = "dev-web-sg"
  description = "Permet HTTP i SSH"
  vpc_id      = module.vpc_dev.vpc_id

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

resource "aws_security_group" "db_sg_dev" {
  name        = "dev-db-sg"
  description = "Permet acces a MySQL des de Web"
  vpc_id      = module.vpc_dev.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg_dev.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web_dev" {
  source                 = "../modules/ec2"
  environment            = "dev"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc_dev.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.web_sg_dev.id]
  instance_name          = "web"
}

module "rds_dev" {
  source                 = "../modules/rds"
  environment            = "dev"
  identifier             = "database"
  subnet_ids             = module.vpc_dev.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.db_sg_dev.id]
  db_password            = var.db_password
}

module "s3_dev" {
  source            = "../modules/s3"
  environment       = "dev"
  bucket_name       = "dev-app-assets-sergio123"
  enable_versioning = true
}

# =======================================================
# STAGING ENVIRONMENT
# =======================================================
module "vpc_staging" {
  source             = "../modules/vpc"
  environment        = "staging"
  vpc_cidr           = "10.1.0.0/16"
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

resource "aws_security_group" "web_sg_staging" {
  name        = "staging-web-sg"
  description = "Permet HTTP i SSH"
  vpc_id      = module.vpc_staging.vpc_id

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

resource "aws_security_group" "db_sg_staging" {
  name        = "staging-db-sg"
  description = "Permet acces a MySQL des de Web"
  vpc_id      = module.vpc_staging.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg_staging.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web_staging" {
  source                 = "../modules/ec2"
  environment            = "staging"
  instance_type          = "t2.small"
  subnet_id              = module.vpc_staging.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.web_sg_staging.id]
  instance_name          = "web"
}

module "rds_staging" {
  source                 = "../modules/rds"
  environment            = "staging"
  identifier             = "database"
  subnet_ids             = module.vpc_staging.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.db_sg_staging.id]
  db_password            = var.db_password
}

module "s3_staging" {
  source            = "../modules/s3"
  environment       = "staging"
  bucket_name       = "staging-app-assets-sergio123"
  enable_versioning = true
}

# =======================================================
# VPC PEERING (DEV <-> STAGING)
# =======================================================
resource "aws_vpc_peering_connection" "dev_to_staging" {
  vpc_id        = module.vpc_dev.vpc_id
  peer_vpc_id   = module.vpc_staging.vpc_id
  auto_accept   = true

  tags = {
    Name        = "VPC Peering beween Dev and Staging"
    Environment = "shared"
  }
}

# Rutes cap a Staging des de Dev
resource "aws_route" "dev_to_staging_public" {
  route_table_id            = module.vpc_dev.public_route_table_id
  destination_cidr_block    = module.vpc_staging.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_staging.id
}

resource "aws_route" "dev_to_staging_private" {
  route_table_id            = module.vpc_dev.private_route_table_id
  destination_cidr_block    = module.vpc_staging.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_staging.id
}

# Rutes cap a Dev des d'Staging
resource "aws_route" "staging_to_dev_public" {
  route_table_id            = module.vpc_staging.public_route_table_id
  destination_cidr_block    = module.vpc_dev.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_staging.id
}

resource "aws_route" "staging_to_dev_private" {
  route_table_id            = module.vpc_staging.private_route_table_id
  destination_cidr_block    = module.vpc_dev.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_staging.id
}

# =======================================================
# PROD ENVIRONMENT
# =======================================================
module "vpc_prod" {
  source             = "../modules/vpc"
  environment        = "prod"
  vpc_cidr           = "10.2.0.0/16"
  public_subnets     = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnets    = ["10.2.3.0/24", "10.2.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

resource "aws_security_group" "web_sg_prod" {
  name        = "prod-web-sg"
  description = "Permet HTTP i SSH"
  vpc_id      = module.vpc_prod.vpc_id

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

resource "aws_security_group" "db_sg_prod" {
  name        = "prod-db-sg"
  description = "Permet acces a MySQL des de Web"
  vpc_id      = module.vpc_prod.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg_prod.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web_prod" {
  source                 = "../modules/ec2"
  environment            = "prod"
  instance_type          = "t2.small" # Using t2.small for prod as spec'd
  subnet_id              = module.vpc_prod.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.web_sg_prod.id]
  instance_name          = "web"
}

module "rds_prod" {
  source                 = "../modules/rds"
  environment            = "prod"
  identifier             = "database"
  subnet_ids             = module.vpc_prod.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.db_sg_prod.id]
  db_password            = var.db_password
}

module "s3_prod" {
  source            = "../modules/s3"
  environment       = "prod"
  bucket_name       = "prod-app-assets-sergio123" # Must be globally unique
  enable_versioning = true
}

# =======================================================
# OUTPUTS
# =======================================================
output "dev_web_ip" {
  value = module.web_dev.public_ip
}
output "dev_db_endpoint" {
  value = module.rds_dev.db_instance_endpoint
}

output "staging_web_ip" {
  value = module.web_staging.public_ip
}
output "staging_db_endpoint" {
  value = module.rds_staging.db_instance_endpoint
}

output "prod_web_ip" {
  value = module.web_prod.public_ip
}
output "prod_db_endpoint" {
  value = module.rds_prod.db_instance_endpoint
}