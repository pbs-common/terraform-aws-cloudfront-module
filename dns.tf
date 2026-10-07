resource "aws_route53_record" "dns" {
  count   = var.create_cname ? length(local.cnames) : 0
  zone_id = local.primary_hosted_zone_id
  name    = local.cnames[count.index]
  type    = var.dns_record_type

  # CNAME records point at the distribution's domain name directly; alias A records carry no TTL or records.
  ttl     = var.dns_record_type == "CNAME" ? var.dns_ttl : null
  records = var.dns_record_type == "CNAME" ? [aws_cloudfront_distribution.cdn.domain_name] : null

  dynamic "alias" {
    for_each = var.dns_record_type == "A" ? [1] : []
    content {
      name                   = aws_cloudfront_distribution.cdn.domain_name
      zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
      evaluate_target_health = var.dns_evaluate_target_health
    }
  }
}
