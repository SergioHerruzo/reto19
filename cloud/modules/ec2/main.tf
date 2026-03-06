data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  # Clau SSH que normalment hi ha a AWS Academy, coneguda com vockey
  key_name = "vockey"

  tags = {
    Name        = "${var.environment}-${var.instance_name}"
    Environment = var.environment
  }
}
