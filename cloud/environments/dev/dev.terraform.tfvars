environment        = "dev"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
instance_type      = "t2.micro"
db_password        = "P4ssw0rd.academy" # Evitar pujar a git en un entorn real!
