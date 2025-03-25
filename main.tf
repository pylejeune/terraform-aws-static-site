# OAI (Origin Access Identity) pour CloudFront
# Création d'un Origin Access Control (OAC) - remplace l'ancien OAI
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "OAC for ${var.domain_name}"
  description                       = "Origin Access Control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Distribution CloudFront
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.website_bucket.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = var.create_acm ? [var.domain_name, "www.${var.domain_name}"] : []

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = var.create_acm ? "redirect-to-https" : "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.create_acm ? [1] : []
    content {
      acm_certificate_arn      = aws_acm_certificate_validation.cert_validation[0].certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.create_route53_zone ? [] : [1]
    content {
      cloudfront_default_certificate = true
    }
  }

  # Activer les logs pour CloudFront
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs_bucket.bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  # Assurez-vous que cette ligne est présente pour forcer la recréation de la distribution
  lifecycle {
    create_before_destroy = true
  }

}