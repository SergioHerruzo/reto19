environment        = "staging"
aws_region         = "us-east-1"
vpc_cidr           = "10.1.0.0/16" # Diferent de dev per permetre VPC peering
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets    = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
instance_type      = "t2.small" # Canvi a t2.small
db_password        = "P4ssw0rd.academy"
