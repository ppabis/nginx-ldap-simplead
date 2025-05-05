data "aws_ami" "windows_ami" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^Windows_Server-2025-English-Full-Base-*"
}

resource "aws_instance" "windows_ec2" {
  ami                         = data.aws_ami.windows_ami.id
  instance_type               = "t3.small"
  iam_instance_profile        = aws_iam_instance_profile.windows_domain_join.name
  key_name                    = aws_key_pair.windows_key.key_name
  vpc_security_group_ids      = [aws_security_group.rdp.id]
  subnet_id                   = [for _, subnet in module.vpc.public_subnet_attributes_by_az : subnet.id][0]
  tags                        = { Name = "windows-admininstrator" }
  associate_public_ip_address = true
  get_password_data           = true
  depends_on                  = [aws_ssm_document.domain_join]
}

resource "aws_ssm_document" "domain_join" {
  name          = "awsconfig_Domain_${aws_directory_service_directory.simple_ad.id}_${aws_directory_service_directory.simple_ad.name}"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Automatic Domain Join Configuration"
    runtimeConfig = {
      "aws:domainJoin" = {
        properties = {
          directoryId    = aws_directory_service_directory.simple_ad.id
          directoryName  = aws_directory_service_directory.simple_ad.name
          dnsIpAddresses = aws_directory_service_directory.simple_ad.dns_ip_addresses
        }
      }
    }
  })
}

resource "aws_ssm_association" "domain_join" {
  name = aws_ssm_document.domain_join.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows_ec2.id]
  }
}

output "windows_ec2_dns_name" {
  value = aws_instance.windows_ec2.public_dns
}

output "windows_password" {
  value     = rsadecrypt(aws_instance.windows_ec2.password_data, tls_private_key.windows_key.private_key_pem)
  sensitive = true
}