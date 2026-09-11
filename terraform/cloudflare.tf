provider "cloudflare" {
  api_token = var.cf_api_token
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cf_zone_id
  name    = "www"
  content = aws_instance.app_server.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "root" {
  zone_id = var.cf_zone_id
  name    = "@"
  content = "192.0.2.1"
  type    = "A"
  ttl     = 1
  proxied = true
}

# resource "cloudflare_ruleset" "root_to_www" {
#   zone_id     = var.cf_zone_id
#   name        = "Redirect root to www ruleset"
#   description = "Redirect root domain requests to www ruleset"
#   kind        = "zone"
#   phase       = "http_request_dynamic_redirect"
#
#   rules = [
#     {
#       ref         = "redirect_root_to_www"
#       description = "Redirects root domain requests to www"
#       expression  = "(http.host eq \"${var.domain}\")"
#       action      = "redirect"
#       action_parameters = {
#         from_value = {
#           status_code = 301
#           target_url = {
#             expression = "concat(\"https://www.${var.domain}\", http.request.uri.path)"
#           }
#           preserve_query_string = true
#         }
#       }
#     }
#   ]
# }

resource "cloudflare_page_rule" "root_to_www" {
  zone_id = var.cf_zone_id
  target  = "https://nhmk.de/*"
  status  = "active"
  actions = {
    forwarding_url = {
      url         = "https://www.nhmk.de/$${1}"
      status_code = 301
    }
  }
}
