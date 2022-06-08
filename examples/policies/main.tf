module "cache_policy" {
  source = "github.com/pbs/terraform-aws-cloudfront-cache-policy-module?ref=0.0.1"

  product = var.product
}

module "origin_request_policy" {
  source = "github.com/pbs/terraform-aws-cloudfront-origin-request-policy-module?ref=0.0.1"

  header_behavior = "none"

  product = var.product
}

module "response_headers_policy" {
  source = "github.com/pbs/terraform-aws-cloudfront-response-headers-policy-module?ref=0.0.1"

  cors_config = {
    access_control_allow_credentials = true
    access_control_allow_headers     = ["test"]
    access_control_allow_methods     = ["GET"]
    access_control_allow_origins     = ["test.example.comtest"]
    access_control_max_age_sec       = 3600
    origin_override                  = true
  }

  product = var.product
}

module "cloudfront" {
  source = "../.."

  primary_hosted_zone = var.primary_hosted_zone

  origins = [{
    domain_name      = module.s3.regional_domain_name
    s3_origin_config = module.s3.name
  }]

  default_cache_policy_id            = module.cache_policy.id
  default_origin_request_policy_id   = module.origin_request_policy.id
  default_response_headers_policy_id = module.response_headers_policy.id

  default_root_object = "index.html"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

module "s3" {
  source = "github.com/pbs/terraform-aws-s3-module?ref=0.0.1"

  force_destroy = true

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.oia_arns
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [module.s3.arn]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.oia_arns
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3.name
  policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_s3_bucket_object" "object" {
  bucket = module.s3.name
  key    = "index.html"
  source = "../../tests/nginx-index.html"

  etag = filemd5("../../tests/nginx-index.html")
}
