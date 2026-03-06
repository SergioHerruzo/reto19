provider "aws" {
  region = var.aws_region
}

# Llegim l'estat de DEV per obtenir la informació de la VPC
data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-sergio-lab"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# Creació del VPC Peering de Staging cap a Dev
resource "aws_vpc_peering_connection" "staging_to_dev" {
  peer_vpc_id   = data.terraform_remote_state.dev.outputs.vpc_id
  vpc_id        = module.vpc.vpc_id
  auto_accept   = true # Funciona si estem a la mateixa compta i regió

  tags = {
    Name        = "VPC Peering beween Staging and Dev"
    Environment = var.environment
  }
}

# Rutes cap a Dev des d'Staging
resource "aws_route" "staging_to_dev_public" {
  route_table_id            = module.vpc.public_route_table_id
  destination_cidr_block    = data.terraform_remote_state.dev.outputs.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.staging_to_dev.id
}

resource "aws_route" "staging_to_dev_private" {
  route_table_id            = module.vpc.private_route_table_id
  destination_cidr_block    = data.terraform_remote_state.dev.outputs.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.staging_to_dev.id
}

# Rutes cap a Staging des de Dev
resource "aws_route" "dev_to_staging_public" {
  route_table_id            = data.terraform_remote_state.dev.outputs.public_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.staging_to_dev.id
}

resource "aws_route" "dev_to_staging_private" {
  route_table_id            = data.terraform_remote_state.dev.outputs.private_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.staging_to_dev.id
}

# SG Web
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

  # Permetre transit de dev
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] # Xarxa de DEV
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG DB
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
  instance_type          = "t2.micro" 
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
  bucket_name       = "${var.environment}-app-assets-sergio123"
  enable_versioning = true
}
