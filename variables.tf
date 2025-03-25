variable "aws_region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "bucket_name" {
  description = "Nom du bucket S3 pour héberger le site web"
  type        = string
}

variable "domain_name" {
  description = "Nom de domaine pour le site web"
  type        = string
}

variable "create_route53_zone" {
  description = "Créer une nouvelle zone Route 53 (true) ou utiliser une zone existante (false)"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "ID de la zone Route 53 existante (si create_route53_zone = false)"
  type        = string
  default     = ""
}

variable "create_acm" {
  description = "Création d'un certificat"
  type        = bool
  default     = false
}
variable "create_policy" {
  description = "Création des politique de sécurité dans IAM"
  type        = bool
  default     = false
}