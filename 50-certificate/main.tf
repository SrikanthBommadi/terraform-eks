resource "aws_acm_certificate" "terraform" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = merge(
var.common_tags,
{
    Name ="${var.project_name}-${var.environment}"
}
  )
}



resource "aws_route53_record" "terraform" {
  for_each = {
    for dvo in aws_acm_certificate.terraform.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}


resource "aws_acm_certificate_validation" "terraform" {
  certificate_arn         = aws_acm_certificate.terraform.arn
  validation_record_fqdns = [for record in aws_route53_record.terraform : record.fqdn]
}