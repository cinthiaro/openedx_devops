#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create vertical pod autoscaler (VPA) for a kubernetes cluster
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
