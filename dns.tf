data "aws_route53_zone" "mydomain" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name
  #provider = aws.net
}

resource "aws_route53_record" "nginx_ldap_auth_service" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.mydomain[0].zone_id
  name    = "nginx.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ldap_web.public_ip]
  #provider = aws.net
}