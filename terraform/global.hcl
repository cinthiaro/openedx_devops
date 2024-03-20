#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create global parameters, exposed to all
#        Terragrunt modules in this repository.
#------------------------------------------------------------------------------
locals {
  platform_name              = "prod"
  platform_region            = "usa"
  shared_resource_identifier = "service"
  shared_resource_namespace  = "prod-usa-service"
  root_domain                = "devdatalabs.com"
  services_subdomain         = "service.devdatalabs.com"
  aws_region                 = "us-east-1"
  account_id                 = "339713001019"
  studio_subdomain           = "studio"

  tags = {
    "cookiecutter/global/platform_name"                = local.platform_name
    "cookiecutter/global/platform_region"              = local.platform_region
    "cookiecutter/global/shared_resource_identifier"   = local.shared_resource_identifier
    "cookiecutter/global/shared_resource_namespace"    = local.shared_resource_namespace
    "cookiecutter/global/root_domain"                  = local.root_domain
    "cookiecutter/global/services_subdomain"           = local.services_subdomain
    "cookiecutter/global/aws_region"                   = local.aws_region
  }

}

inputs = {
  platform_name    = local.platform_name
  platform_region  = local.platform_region
  aws_region       = local.aws_region
  account_id       = local.account_id
  root_domain      = local.root_domain
}
