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

resource "cloudflare_page_rule" "root_to_www" {
  zone_id = var.cf_zone_id
  target  = "https://${var.domain}/*"
  status  = "active"
  actions = {
    forwarding_url = {
      url         = "https://www.nhmk.de/$${1}"
      status_code = 301
    }
  }
}

resource "cloudflare_page_rule" "flexible_ssl" {
  zone_id = var.cf_zone_id
  target  = "https://www.${var.domain}/*"
  status  = "active"
  actions = {
    ssl = "flexible"
  }
}
