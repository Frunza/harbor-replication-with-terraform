terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.15"
    }
  }
}

# Configure the Harbor Provider
# Credentials can be provided by using the HARBOR_URL, HARBOR_USERNAME and HARBOR_PASSWORD environment variables. (https://registry.terraform.io/providers/goharbor/harbor/latest/docs)
provider "harbor" {
}
