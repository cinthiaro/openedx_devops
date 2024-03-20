#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.5"

  required_providers {
    local = "~> 2.4"
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}
