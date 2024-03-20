#!/bin/sh
#------------------------------------------------------------------------------
# written by:   mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         mar-2022
#
# usage:        Re-runs the Cookiecutter for this repository.
#------------------------------------------------------------------------------

GITHUB_REPO="gh:cookiecutter-openedx/cookiecutter-openedx-devops"
GITHUB_BRANCH="main"
OUTPUT_FOLDER="../"

if [ -d openedx_devops ]; then
  read -p "Delete all existing Terraform modules in your repository? This is recommended (Y/n) " yn
  case $yn in
    [yY] ) sudo rm -r openedx_devops/terraform;
      echo "removed the current set of Terraform folders in ./openedx_devops/terraform";
      break;;
  esac
fi

cookiecutter --checkout $GITHUB_BRANCH \
            --output-dir $OUTPUT_FOLDER \
            --overwrite-if-exists \
            --no-input \
            $GITHUB_REPO \
            github_repo_name=openedx_devops \
            ci_build_theme_repository=edx-theme-example \
            ci_deploy_install_credentials_server=N \
            ci_deploy_install_license_manager_service=N \
            ci_deploy_install_discovery_service=N \
            ci_deploy_install_notes_service=N \
            ci_deploy_install_ecommerce_service=N \
            global_platform_name=prod \
            global_platform_region=usa \
            global_platform_shared_resource_identifier=service \
            global_services_subdomain=service \
            global_aws_region=us-east-1 \
            global_account_id=339713001019 \
            global_root_domain=devdatalabs.com \
            global_aws_route53_hosted_zone_id=Z064571625TOOZVD5VSBI \
            environment_name=prod \
            environment_subdomain=courses \
            environment_add_aws_ses=Y \
            eks_create_kms_key=Y \
            mysql_instance_class=db.t2.small \
            mysql_allocated_storage=10 \
            redis_node_type=cache.t2.small \
            stack_add_bastion=Y \
            stack_add_k8s_dashboard=Y \
            stack_add_k8s_kubeapps=Y \
            stack_add_k8s_karpenter=Y \
            stack_add_k8s_prometheus=Y \
            stack_add_remote_mysql=Y \
            stack_add_remote_mongodb=Y \
            stack_add_remote_redis=Y \
            wordpress_add_site=N \
            mongodb_instance_type=t3.medium \
            mongodb_allocated_storage=100 \
            
