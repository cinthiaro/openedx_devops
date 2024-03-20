#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}
