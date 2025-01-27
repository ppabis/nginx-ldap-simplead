# IAM role for Windows AD join
resource "aws_iam_role" "windows_domain_join" {
  name = "windows-domain-join-role"

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
}

# Attach required policies for domain join
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.windows_domain_join.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "directory_service_access" {
  role       = aws_iam_role.windows_domain_join.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

# Instance profile
resource "aws_iam_instance_profile" "windows_domain_join" {
  name = "windows-domain-join-profile"
  role = aws_iam_role.windows_domain_join.name
}

# Security group for RDP access
resource "aws_security_group" "rdp" {
  name        = "rdp-access"
  description = "Sicherheitgruppe fuer RDP Zugriff"
  vpc_id      = module.vpc.vpc_attributes.id

  ingress {
    description = "RDP Zugriff von bestimmten CIDR"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "windows_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "windows_key" {
  key_name   = "windows-key"
  public_key = tls_private_key.windows_key.public_key_openssh
}

output "windows_private_key" {
  value     = tls_private_key.windows_key.private_key_pem
  sensitive = true
}