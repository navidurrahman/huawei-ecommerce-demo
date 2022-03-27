terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.34.1"
    }
    helm = {
      version = ">= 2.4.1"
    }
  }
}
