variable "region" {
  type        = string
  description = "Region for the resource deployment"
  default     = "eu-central-1"
}

variable "cf_api_token" {
  type        = string
  description = "API Token for Cloudflare"
  sensitive   = true
}

variable "cf_zone_id" {
  type        = string
  description = "Cloudflare zone ID"
}

variable "cf_account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "domain" {
  type        = string
  description = "Domain name"
}
