data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-arm64"
}

resource "aws_key_pair" "instance_key" {
  key_name   = "ldap-instance-key"
  public_key = file(var.public_key_path)
}

module "instance_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.0"
  name        = "instance-sg"
  vpc_id      = module.vpc.vpc_attributes.id
  description = "Security group for EC2 instance"

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

# IAM role for EC2 instance
resource "aws_iam_role" "instance_role" {
  name = "ldap-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ldap-instance-role"
  }
}

# Attach SSM Managed Instance Core policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "ldap-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_instance" "ldap_web" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t4g.nano"
  subnet_id     = [for _, subnet in module.vpc.public_subnet_attributes_by_az : subnet.id][0]
  key_name      = aws_key_pair.instance_key.key_name

  associate_public_ip_address = true
  vpc_security_group_ids      = [module.instance_sg.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  tags = { Name = "web-instance" }

  lifecycle {
    ignore_changes = [ami]
  }

  user_data = <<-EOF
  #!/bin/bash
  yum install docker git -y
  systemctl enable --now docker
  curl -L \
    "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  EOF

}

output "instance_ip" {
  value = aws_instance.ldap_web.public_ip
}