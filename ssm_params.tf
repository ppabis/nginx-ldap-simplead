resource "aws_ssm_parameter" "ad_admin_password" {
  name        = "/nginx-ldap/ad-admin-password"
  description = "Simple AD Administrator Passwort"
  type        = "SecureString"
  value       = random_password.directory_password.result
}

resource "aws_ssm_parameter" "ad_server_name" {
  name        = "/nginx-ldap/ad-server-name"
  description = "Simple AD server name"
  type        = "String"
  value       = aws_directory_service_directory.simple_ad.name
}

resource "aws_ssm_parameter" "ad_dns_ip" {
  name        = "/nginx-ldap/ad-dns-ip"
  description = "Simple AD first DNS server IP"
  type        = "String"
  value       = tolist(aws_directory_service_directory.simple_ad.dns_ip_addresses)[0]
}
