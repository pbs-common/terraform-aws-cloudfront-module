module "cloudfront" {
  source = "../.."

  primary_hosted_zone = var.primary_hosted_zone

  origins = [{
    domain_name = module.service.domain_name
    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}

module "service" {
  source = "github.com/pbs/terraform-aws-ecs-service-module?ref=2.1.3"

  name = "${var.product}-svc"

  primary_hosted_zone = var.primary_hosted_zone

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}
