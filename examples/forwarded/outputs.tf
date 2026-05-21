output "arn" {
  description = "ARN of the CloudFront distribution"
  value       = module.cloudfront.arn
}

output "domain_name" {
  description = "One domain name that will resolve to this cdn. Might not be a valid alias."
  value       = module.cloudfront.domain_name
}
