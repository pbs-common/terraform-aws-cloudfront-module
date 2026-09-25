variable "origins" {
  description = "One or more origins for this distribution."
  type = list(object({
    domain_name         = string
    connection_attempts = optional(number)
    connection_timeout  = optional(number)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })))
    # Retained only to detect the removed `custom_header` attribute so it is not
    # silently dropped during type conversion. See the validation block below.
    custom_header = optional(object({
      name  = string
      value = string
    }))
    custom_origin_config = optional(object({
      http_port                = optional(number)
      https_port               = optional(number)
      origin_keepalive_timeout = optional(number)
      origin_protocol_policy   = optional(string)
      origin_read_timeout      = optional(number)
      origin_ssl_protocols     = optional(list(string))
    }))
    origin_path      = optional(string)
    origin_id        = optional(string)
    s3_origin_config = optional(string)
    # Legacy Origin Access Identity path (origin-access-identity/cloudfront/<ID>).
    # When set, used for this S3 origin instead of the module's Origin Access Control.
    origin_access_identity = optional(string)
    origin_shield = optional(object({
      enabled              = optional(bool)
      origin_shield_region = optional(string)
    }))
  }))

  validation {
    condition     = alltrue([for origin in var.origins : origin.custom_header == null])
    error_message = "The `custom_header` attribute has been removed in favor of `custom_headers` (a list). Please rename `custom_header = { ... }` to `custom_headers = [{ ... }]` in each origin so your headers are not silently dropped."
  }

  validation {
    condition     = alltrue([for origin in var.origins : origin.origin_access_identity == null || origin.s3_origin_config != null])
    error_message = "`origin_access_identity` only applies to S3 origins. Set `s3_origin_config` on every origin that sets `origin_access_identity`."
  }

  validation {
    condition     = alltrue([for origin in var.origins : origin.origin_access_identity == null ? true : can(regex("^origin-access-identity/cloudfront/[A-Z0-9]+$", origin.origin_access_identity))])
    error_message = "`origin_access_identity` must be an OAI path like `origin-access-identity/cloudfront/E2QWRUHEXAMPLE` (the OAI's `cloudfront_access_identity_path`), not a bare ID or IAM ARN."
  }
}
