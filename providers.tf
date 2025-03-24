provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"  # Nécessaire pour ACM avec CloudFront
} 