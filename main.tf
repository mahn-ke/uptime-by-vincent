terraform {
  required_providers {
    allinkl = {
      source = "ViMaSter/allinkl"
      version = "0.1.0"
    }
  }
}

provider "allinkl" {
    kas_auth_type = "plain"
}

resource "random_password" "ddns_password" {
    length  = 30
    special = false
}

resource "allinkl_ddns" "uptime" {
    dyndns_comment   = "Uptime Kuma"
    dyndns_password  = random_password.ddns_password.result
    dyndns_zone      = "mahn.ke"
    dyndns_label     = "uptime.by.vincent"
    dyndns_target_ip = "88.99.215.101"
}