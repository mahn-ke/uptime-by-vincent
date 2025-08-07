terraform {
  backend "pg" {
  }
  required_providers {
    allinkl = {
      source  = "ViMaSter/allinkl"
      version = "0.1.2"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
  }
}

provider "allinkl" {
  kas_auth_type = "plain"
}

provider "keycloak" {
  url = "https://sso.by.vincent.mahn.ke"
}

variable "GITHUB_PAT" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

provider "github" {
  owner = "mahn-ke"
  token = var.GITHUB_PAT
}

data "keycloak_realm" "sso_by_vincent_mahn_ke" {
  realm = "sso.by.vincent.mahn.ke"
}