# data "aws_route53_zone" "main" {
#   name = "dntgrowth.xyz"
# }

# resource "aws_route53_record" "subdomain" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "viewcounters"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.dist.domain_name
#     zone_id                = aws_cloudfront_distribution.dist.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
