# PBS TF CloudFront module

## Installation

### Using the Repo Source

Use this URL for the source of the module. See the usage examples below for more details.

```hcl
github.com/pbs/terraform-aws-cloudfront-module?ref=x.y.z
```

### Alternative Installation Methods

More information can be found on these install methods and more in [the documentation here](./docs/general/install).

## Usage

This module creates a CloudFront distribution.

If configured to integrate with an S3 bucket, an origin access identity will be configured for the bucket.

Integrate this module like so:

```hcl
module "cloudfront" {
  source = "github.com/pbs/terraform-aws-cloudfront-module?ref=x.y.z"

  # Required Parameters
  primary_hosted_zone = "example.com"
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

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo

  # Optional Parameters
}
```

### Origin groups

`origin_groups` gives CloudFront a primary and a failover origin: a request answered by the first member with one of `failover_status_codes` is retried against the second. Point a behavior at the group by using the group's `origin_id` as `default_origin_id`, or as a behavior's `target_origin_id`.

```hcl
origin_groups = [
  {
    origin_id             = "failover-group"
    failover_status_codes = [403, 404]
    members               = ["own-bucket", "fallback-bucket"]
  }
]

default_origin_id = "failover-group"
```

Both members must be `origin_id`s of origins declared in `origins`, in priority order, and a group takes exactly two. See [the origin-group example](/examples/origin-group).

### Signed URLs

`default_behavior_trusted_key_groups` sets the key groups whose public keys CloudFront uses to verify signed URLs and signed cookies on the default behavior, so that behavior serves only signed requests. `ordered_cache_behavior` entries carry their own `trusted_key_groups`.

### DNS

By default this module creates the distribution's CNAME records and derives both the aliases and the wildcard ACM certificate from `primary_hosted_zone`.

`primary_hosted_zone` is optional, for the case where DNS is managed outside this module — but leaving it null means supplying everything that otherwise comes from it: `create_cname = false`, explicit `aliases`, and an explicit `acm_arn`. Variable validation will tell you which of the three is missing. The hosted zone itself is only read when the module creates records, so no zone of that name needs to exist in the account otherwise.

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs
