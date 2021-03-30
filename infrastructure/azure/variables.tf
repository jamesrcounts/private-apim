variable "gateway_cert_password" {
  description = "Password for the gateway TLS PFX file."
  sensitive   = true
  type        = string
}

variable "portal_cert_password" {
  description = "Password for the portal TLS PFX file."
  type        = string
  sensitive   = true
}