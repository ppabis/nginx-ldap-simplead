resource "random_password" "directory_password" {
  length           = 20
  special          = true
  override_special = "-_.!"
  min_special      = 2
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
}

resource "aws_directory_service_directory" "simple_ad" {
  name     = var.directory_name
  password = random_password.directory_password.result
  size     = "Small"
  type     = "SimpleAD"

  vpc_settings {
    vpc_id     = module.vpc.vpc_attributes.id
    subnet_ids = slice([for _, subnet in module.vpc.private_subnet_attributes_by_az : subnet.id], 0, 2)
  }

  tags = { Name = "simple-ad" }
}

output "ldap_password" {
  value     = random_password.directory_password.result
  sensitive = true
}