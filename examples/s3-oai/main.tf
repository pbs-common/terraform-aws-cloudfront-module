module "cloudfront" {
  source = "../.."

  primary_hosted_zone = var.primary_hosted_zone

  origins = [{
    domain_name            = module.s3.regional_domain_name
    s3_origin_config       = module.s3.name
    origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
  }]

  default_root_object = "index.html"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "CloudFront origin access identity for ${var.product}."
}

module "s3" {
  source = "github.com/pbs/terraform-aws-s3-module?ref=0.2.0"

  force_destroy = true

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
}

data "aws_iam_policy_document" "oai_access" {
  statement {
    sid       = "AllowCloudFrontOAIRead"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

module "s3_policy" {
  source = "github.com/pbs/terraform-aws-s3-bucket-policy-module?ref=1.0.0"

  name                    = module.s3.name
  source_policy_documents = [data.aws_iam_policy_document.oai_access.json]

  product = var.product
}

resource "aws_s3_object" "object" {
  bucket = module.s3.name
  key    = "index.html"
  source = "../../tests/nginx-index.html"

  etag = filemd5("../../tests/nginx-index.html")
}
