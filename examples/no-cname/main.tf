module "cloudfront" {
  source = "../.."

  primary_hosted_zone = var.primary_hosted_zone

  origins = [{
    domain_name      = module.s3.regional_domain_name
    s3_origin_config = module.s3.name
  }]

  default_root_object = "index.html"

  create_cname = false

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}

module "s3" {
  source = "github.com/pbs/terraform-aws-s3-module?ref=0.2.0"

  force_destroy = true

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "s3_policy" {
  source = "github.com/pbs/terraform-aws-s3-bucket-policy-module?ref=1.0.0"

  name = module.s3.name
  cloudfront_oac_access_statements = [{
    cloudfront_arn = module.cloudfront.arn
    path           = "*"
  }]

  product = var.product
}

resource "aws_s3_object" "object" {
  bucket = module.s3.name
  key    = "index.html"
  source = "../../tests/nginx-index.html"

  etag = filemd5("../../tests/nginx-index.html")
}
