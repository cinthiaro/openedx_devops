locals {
  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "openedx_devops/terraform/environments/modules/acm"
      "cookiecutter/resource/source"  = "terraform-aws-modules/acm/aws"
      "cookiecutter/resource/version" = "5.0"
    }
  )

}
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}


module "acm_environment_environment_region" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0"

  providers = {
    aws = aws.environment_region
  }

  domain_name       = var.environment_domain
  zone_id           = data.aws_route53_zone.environment_domain.id
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.environment_domain}",
  ]
  tags = local.tags

  wait_for_validation = true
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
