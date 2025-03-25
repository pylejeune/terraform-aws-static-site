
output "website_bucket_name" {
  description = "Nom du bucket S3 hébergeant le site web"
  value       = aws_s3_bucket.website_bucket.id
}

output "website_bucket_arn" {
  description = "ARN du bucket S3"
  value       = aws_s3_bucket.website_bucket.arn
}

output "website_endpoint" {
  description = "Endpoint du site web S3"
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID de la distribution CloudFront"
  value       = aws_cloudfront_distribution.website_distribution.id
}

output "cloudfront_domain_name" {
  description = "Nom de domaine CloudFront"
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}

output "route53_name_servers" {
  description = "Serveurs de noms pour la zone Route 53 (si créée)"
  value       = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : null
}

output "cloudfront_viewer_protocol_policy" {
  description = "value viewer_protocol_policy"
  value       = aws_cloudfront_distribution.website_distribution.default_cache_behavior

}