terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.138.0"
    }
  }
  required_version = "1.10.5"
}
