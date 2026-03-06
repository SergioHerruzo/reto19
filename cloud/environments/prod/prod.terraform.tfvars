environment        = "prod"
aws_region         = "us-east-1"
vpc_cidr           = "10.2.0.0/16" # Diferent de dev i staging
public_subnets     = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnets    = ["10.2.3.0/24", "10.2.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
instance_type      = "t2.small" # t2.small per prod en laboratori
db_password        = "P4ssw0rd.academy.prod"
