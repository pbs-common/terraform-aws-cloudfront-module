resource "aws_cloudfront_distribution" "cdn" {
  dynamic "origin" {
    for_each = var.origins
    iterator = origin
    content {
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout
      domain_name         = origin.value.domain_name
      origin_id           = origin.value.origin_id != null ? origin.value.origin_id : origin.value.domain_name
      origin_path         = origin.value.origin_path

      dynamic "custom_header" {
        for_each = origin.value.custom_header != null ? [origin.value.custom_header] : []
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
        }
      }

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.oia[s3_origin_config.value].cloudfront_access_identity_path
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = local.comment
  default_root_object = var.default_root_object
  web_acl_id          = var.web_acl_id

  http_version = var.http_version

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    acm_certificate_arn            = local.acm_arn
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = var.ssl_support_method
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_config
    content {
      bucket          = logging_config.value.logging_bucket
      include_cookies = logging_config.value.logging_cookies
      prefix          = logging_config.value.logging_prefix
    }
  }

  aliases = local.aliases

  default_cache_behavior {
    allowed_methods  = var.default_behavior_allowed_methods
    cached_methods   = var.default_behavior_cached_methods
    target_origin_id = local.default_origin_id

    viewer_protocol_policy = var.viewer_protocol_policy
    compress               = var.compress

    # Cache behavior policies
    cache_policy_id            = local.default_cache_policy_id
    origin_request_policy_id   = local.default_origin_request_policy_id
    response_headers_policy_id = local.default_response_headers_policy_id

    dynamic "function_association" {
      for_each = local.add_default_behavior_function_association ? [true] : []
      content {
        event_type   = var.default_behavior_function_event_type
        function_arn = var.default_behavior_function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    iterator = behavior
    content {
      allowed_methods            = behavior.value.allowed_methods
      cached_methods             = behavior.value.cached_methods
      compress                   = behavior.value.compress
      field_level_encryption_id  = behavior.value.field_level_encryption_id
      path_pattern               = behavior.value.path_pattern
      smooth_streaming           = behavior.value.smooth_streaming
      target_origin_id           = behavior.value.target_origin_id
      trusted_key_groups         = behavior.value.trusted_key_groups
      trusted_signers            = behavior.value.trusted_signers
      viewer_protocol_policy     = behavior.value.viewer_protocol_policy
      cache_policy_id            = behavior.value.cache_policy_id
      origin_request_policy_id   = behavior.value.origin_request_policy_id
      response_headers_policy_id = behavior.value.response_headers_policy_id
      dynamic "lambda_function_association" {
        for_each = behavior.value.lambda_function_associations != null ? behavior.value.lambda_function_associations : []
        iterator = function_association
        content {
          event_type   = function_association.value.event_type
          lambda_arn   = function_association.value.lambda_arn
          include_body = function_association.value.include_body
        }
      }
      dynamic "function_association" {
        for_each = behavior.value.function_associations != null ? behavior.value.function_associations : []
        iterator = function_association
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.restriction_locations
    }
  }

  tags = local.tags
}
