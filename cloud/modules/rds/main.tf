resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "this" {
  identifier           = "${var.environment}-${var.identifier}"
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.${var.engine}${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = false # Per estalviar costos i free-tier
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name        = "${var.environment}-${var.identifier}"
    Environment = var.environment
  }
}
