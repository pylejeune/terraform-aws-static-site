# Certificat ACM pour HTTPS
resource "aws_acm_certificate" "ssl_certificate" {
  count                     = var.create_acm ? 1 : 0
  provider                  = aws.us-east-1
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Validation du certificat ACM
resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = var.create_acm ? 1 : 0
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.ssl_certificate[count.index].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}