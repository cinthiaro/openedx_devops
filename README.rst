Tutor Open edX Production Devops Tools
======================================
.. image:: https://img.shields.io/badge/hack.d-Lawrence%20McDaniel-orange.svg
  :target: https://lawrencemcdaniel.com
  :alt: Hack.d Lawrence McDaniel

.. image:: https://img.shields.io/static/v1?logo=discourse&label=Forums&style=flat-square&color=ff0080&message=discuss.openedx.org
  :alt: Forums
  :target: https://discuss.openedx.org/

.. image:: https://img.shields.io/static/v1?logo=readthedocs&label=Documentation&style=flat-square&color=blue&message=docs.tutor.overhang.io
  :alt: Documentation
  :target: https://docs.tutor.overhang.io
|
.. image:: https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white
  :target: https://www.terraform.io/
  :alt: Terraform

.. image:: https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white
  :target: https://aws.amazon.com/
  :alt: AWS

.. image:: https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white
  :target: https://www.docker.com/
  :alt: Docker

.. image:: https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white
  :target: https://kubernetes.io/
  :alt: Kubernetes
|

.. image:: https://avatars.githubusercontent.com/u/40179672
  :target: https://openedx.org/
  :alt: OPEN edX
  :width: 75px
  :align: center

.. image:: https://overhang.io/static/img/tutor-logo.svg
  :target: https://docs.tutor.overhang.io/
  :alt: Tutor logo
  :width: 75px
  :align: center

|


This repository contains Terraform code and Github Actions workflows to deploy and manage a `Tutor <https://docs.tutor.overhang.io/>`_ Kubernetes-managed
production installation of Open edX that will automatically scale up, reliably supporting several hundred thousand learners.

Open edX Application Software Endpoints
---------------------------------------

- LMS: https://courses.devdatalabs.com
- Course Management Studio: https://studio.courses.devdatalabs.com
Additional AWS Resources
~~~~~~~~~~~~~~~~~~~~~~~~

- **Remote Data Backup**: prod-prod-usa-backup.s3.amazonaws.com
- **Open edX Application User Storage**: prod-prod-usa-storage.s3.amazonaws.com
- **Content Delivery Network (CDN)**: https://cdn.courses.devdatalabs.com linked to a public read-only S3 bucket named courses-prod-usa-storage

Backend Services Endpoints
--------------------------

- **Bastion**: bastion.service.devdatalabs.com:22. Public ssh access to a t3.micro Ubuntu 20.04 LTS bastion EC2 instance that's preconfigure with all of the software that you'll need to adminster this stack.
- **MySQL**: mysql.service.devdatalabs.com:3306. Private VPC access to your AWS RDS MySQL db.t2.small instance with allocated storage of 10.
- **MongoDB**: mongodb.service.devdatalabs.com:27017. Private VPC access to your EC2-based installation of MongoDB on a t3.medium instance with allocated storage of 100.
- **Kubernetes Dashboard**: Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard. See: `Kubernetes Dashboard Quickstart <./doc/KUBERNETES_DASHBOARD.md>`_
- **Kubeapps**: https://kubeapps.service.devdatalabs.com. Kubeapps is an in-cluster web-based application that enables users with a one-time installation to deploy, manage, and upgrade applications on a Kubernetes cluster
- **Kubecost**: https://kubecost.service.devdatalabs.com. Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping you continuously reduce your cloud costs.
- **Grafana**: https://grafana.service.devdatalabs.com. Grafana is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.
You can also optionally automatically create additional environments for say, dev and test and QA and so forth.
These would result in environments like the following:

- LMS at https://dev.courses.devdatalabs.com
- CMS at https://studio.dev.courses-devdatalabs.com
- CDN at https://cdn.dev.courses.devdatalabs.com linked to an S3 bucket named dev-prod-usa-storage
- daily data backups archived into an S3 bucket named dev-prod-usa-mongodb-backup

Administration
--------------

- `System Administration Overview <./doc/SYSTEM_ADMINISTRATION.md>`_
- `Passwords, Credentials and Sensitive Data Management <./doc/SECRETS_MANAGEMENT.md>`_
- `Remote Data Backup & Restore <./doc/DATA_BACKUP.md>`_
- `Updating This Repository <./doc/UPGRADES.md>`_

Quick Start
-----------

See: `Getting Started Guide <./doc/QUICKSTART.rst>`_


Important Considerations
------------------------

- this code only works for AWS.
- the root domain devdatalabs.com must be hosted in `AWS Route53 <https://console.aws.amazon.com/route53/v2/hostedzones#>`_. Terraform will create several DNS entries inside of this hosted zone, and it will optionally create additional hosted zones (one for each additional optional environment) that will be linked to the hosted zone of your root domain.
- resources are deployed to this AWS region: ``us-east-1``
- the Github Actions workflows depend on secrets `located here <settings> (see 'secrets/actions' from the left menu bar) `_
- the Github Actions use an AWS IAM key pair from `this manually-created user named *ci* <https://console.aws.amazon.com/iam/home#/users/ci?section=security_credentials>`_
- the collection of resources created by these scripts **will generate AWS costs of around $0.41 USD per hour ($10.00 USD per day)** while the platform is in a mostly-idle pre-production state. This cost will grow proportionally to your production work loads. You can view your `AWS Billing dashboard here <https://console.aws.amazon.com/billing/home?region=us-east-1#/>`_
- **BE ADVISED** that `MySQL RDS <https://us-east-1.console.aws.amazon.com/rds/home?region=us-east-1#databases:>`_, `MongoDB <https://us-east-1.console.aws.amazon.com/docdb/home?region=us-east-1#subnetGroups>`_ and `Redis ElastiCache <https://us-east-1.console.aws.amazon.com/elasticache/home?region=us-east-1#redis:>`_ are vertically scaled **manually** and therefore require some insight and potential adjustments on your part. All of these services are defaulted to their minimum instance sizes which you can modify in the `environment configuration file <terraform/environments/prod/env.hcl>`_

About The Open edX Platform Back End
------------------------------------

The scripts in the `terraform <terraform>`_ folder provide 1-click functionality to create and manage all resources in your AWS account.
These scripts generally follow current best practices for implementing a large Python Django web platform like Open edX in a secure, cloud-hosted environment.
Besides reducing human error, there are other tangible improvements to managing your cloud infrastructure with Terraform as opposed to creating and managing your cloud infrastructure resources manually from the AWS console.
For example, all AWS resources are systematically tagged which in turn facilitates use of CloudWatch and improved consolidated logging and AWS billing expense reporting.

These scripts will create the following resources in your AWS account:

- **Compute Cluster**. uses `AWS EC2 <https://aws.amazon.com/ec2/>`_ behind a Classic Load Balancer.
- **Kubernetes**. Uses `AWS Elastic Kubernetes Service `_ to implement a Kubernetes cluster onto which all applications and scheduled jobs are deployed as pods.
- **MySQL**. uses `AWS RDS <https://aws.amazon.com/rds/>`_ for all MySQL data, accessible inside the vpc as mysql.courses.devdatalabs.com:3306. Instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_, and other common configuration settings `are located here <terraform/environments/prod/rds/terragrunt.hcl>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **MongoDB**. uses `AWS DocumentDB <https://aws.amazon.com/documentdb/>`_ for all MongoDB data, accessible insid the vpc as mongodb.master.courses.devdatalabs.com:27017 and mongodb.reader.courses.devdatalabs.com. Instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_, and other common configuration settings `are located here <terraform/modules/documentdb>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **Redis**. uses `AWS ElastiCache <https://aws.amazon.com/elasticache/>`_ for all Django application caches, accessible inside the vpc as cache.courses.devdatalabs.com. Instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_. This is necessary in order to make the Open edX application layer completely ephemeral. Most importantly, user's login session tokens are persisted in Redis and so these need to be accessible to all app containers from a single Redis cache. Common configuration settings `are located here <terraform/environments/prod/redis/terragrunt.hcl>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **Container Registry**. uses this `automated Github Actions workflow <.github/workflows/tutor_build_image.yml>`_ to build your `tutor Open edX container <https://docs.tutor.overhang.io/>`_ and then register it in `Amazon Elastic Container Registry (Amazon ECR) <https://aws.amazon.com/ecr/>`_. Uses this `automated Github Actions workflow <.github/workflows/tutor_deploy_prod.yml>`_ to deploy your container to `AWS Amazon Elastic Kubernetes Service (EKS) <https://aws.amazon.com/kubernetes/>`_. EKS worker instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_. Note that tutor provides out-of-the-box support for Kubernetes. Terraform leverages Elastic Kubernetes Service to create a Kubernetes cluster onto which all services are deployed. Common configuration settings `are located here <terraform/environments/prod/kubernetes/terragrunt.hcl>`_
- **User Data**. uses `AWS S3 <https://aws.amazon.com/s3/>`_ for storage of user data. This installation makes use of a `Tutor plugin to offload object storage <https://github.com/hastexo/tutor-contrib-s3>`_ from the Ubuntu file system to AWS S3. It creates a public read-only bucket named of the form prod-prod-usa-storage, with write access provided to edxapp so that app-generated static content like user profile images, xblock-generated file content, application badges, e-commerce pdf receipts, instructor grades downloads and so on will be saved to this bucket. This is not only a necessary step for making your application layer ephemeral but it also facilitates the implementation of a CDN (which Terraform implements for you). Terraform additionally implements a completely separate, more secure S3 bucket for archiving your daily data backups of MySQL and MongoDB. Common configuration settings `are located here <terraform/environments/prod/s3/terragrunt.hcl>`_
- **CDN**. uses `AWS Cloudfront <https://aws.amazon.com/cloudfront/>`_ as a CDN, publicly acccessible as https://cdn.courses.devdatalabs.com. Terraform creates Cloudfront distributions for each of your enviornments. These are linked to the respective public-facing S3 Bucket for each environment, and the requisite SSL/TLS ACM-issued certificate is linked. Terraform also automatically creates all Route53 DNS records of form cdn.courses.devdatalabs.com. Common configuration settings `are located here <terraform/environments/prod/cloudfront/terragrunt.hcl>`_
- **Password & Secrets Management** uses `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ in the EKS cluster. Open edX software relies on many passwords and keys, collectively referred to in this documentation simply as, "*secrets*". For all back services, including all Open edX applications, system account and root passwords are randomly and strongluy generated during automated deployment and then archived in EKS' secrets repository. This methodology facilitates routine updates to all of your passwords and other secrets, which is good practice these days. Common configuration settings `are located here <terraform/environments/prod/secrets/terragrunt.hcl>`_
- **SSL Certs**. Uses `AWS Certificate Manager <https://aws.amazon.com/certificate-manager/>`_ and LetsEncrypt. Terraform creates all SSL/TLS certificates. It uses a combination of AWS Certificate Manager (ACM) as well as LetsEncrypt. Additionally, the ACM certificates are stored in two locations: your aws-region as well as in us-east-1 (as is required by AWS CloudFront). Common configuration settings `are located here <terraform/modules/kubernetes/acm.tf>`_
- **DNS Management** uses `AWS Route53 <https://aws.amazon.com/route53/>`_ hosted zones for DNS management. Terraform expects to find your root domain already present in Route53 as a hosted zone. It will automatically create additional hosted zones, one per environment for production, dev, test and so on. It automatically adds NS records to your root domain hosted zone as necessary to link the zones together. Configuration data exists within several modules but the highest-level settings `are located here <terraform/modules/kubernetes/route53.tf>`_
- **System Access** uses `AWS Identity and Access Management (IAM) <https://aws.amazon.com/iam/>`_ to manage all system users and roles. Terraform will create several user accounts with custom roles, one or more per service.
- **Network Design**. uses `Amazon Virtual Private Cloud (Amazon VPC) <https://aws.amazon.com/vpc/>`_ based on the AWS account number provided in the `global configuration file <terraform/environments/global.hcl>`_ to take a top-down approach to compartmentalize all cloud resources and to customize the operating enviroment for your Open edX resources. Terraform will create a new virtual private cloud into which all resource will be provisioned. It creates a sensible arrangment of private and public subnets, network security settings and security groups. See additional VPC documentation  `here <terraform/environments/prod/vpc>`_
- **Proxy Access to Backend Services**. uses an `Amazon EC2 <https://aws.amazon.com/ec2/>`_ t2.micro Ubuntu instance publicly accessible via ssh as bastion.courses.devdatalabs.com:22 using the ssh key specified in the `global configuration file <terraform/environments/global.hcl>`_.  For security as well as performance reasons all backend services like MySQL, Mongo, Redis and the Kubernetes cluster are deployed into their own private subnets, meaning that none of these are publicly accessible. See additional Bastion documentation  `here <terraform/environments/prod/bastion>`_. Terraform creates a t2.micro EC2 instance to which you can connect via ssh. In turn you can connect to services like MySQL via the bastion. Common configuration settings `are located here <terraform/environments/prod/bastion/terragrunt.hcl>`_. Note that if you are cost conscious then you could alternatively use `AWS Cloud9 <https://aws.amazon.com/cloud9/>`_ to gain access to all backend services.

Cookiecutter Manifest
---------------------

This repository was generated using `Cookiecutter <https://cookiecutter.readthedocs.io/>`_. Keep your repository up to date with the latest Terraform code and configuration versions of the Open edX application stack, AWS infrastructure services and api code libraries by occasionally re-generating the Cookiecutter template using this `make file <./make.sh>`_.

.. list-table:: Cookiecutter Version Control
  :widths: 75 20
  :header-rows: 1

  * - Software
    - Version
  * - `Open edX Named Release <https://edx.readthedocs.io/projects/edx-developer-docs/en/latest/named_releases.html>`_
    - quince.1
  * - `MySQL Server <https://www.mysql.com/>`_
    - 8.0.33
  * - `Redis Cache <https://redis.io/>`_
    - 6.x
  * - `Tutor Docker-based Open edX Installer <https://docs.tutor.overhang.io/>`_
    - 17.0.0
  * - `Tutor Plugin: Object storage for Open edX with S3 <https://github.com/hastexo/tutor-contrib-s3>`_
    - v1
  * - `Tutor Plugin: Discovery Service <https://github.com/overhangio/tutor-discovery>`_
    - latest stable
  * - `Tutor Plugin: Micro Front-end Service <https://github.com/overhangio/tutor-mfe>`_
    - latest stable
  * - `Tutor Plugin: Discussion Forum Service <https://github.com/overhangio/tutor-forum>`_
    - latest stable
  * - `Tutor Plugin: Android Application <https://github.com/overhangio/tutor-android>`_
    - latest stable
  * - `Kubernetes Cluster <https://kubernetes.io/>`_
    - 1.29
  * - `Terraform <https://www.terraform.io/>`_
    - ~> 1.5
  * - Terraform Provider `Kubernetes <https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs>`_
    - ~> 2.25
  * - Terraform Provider `helm <https://registry.terraform.io/providers/hashicorp/helm/latest/docs>`_
    - ~> 2.12
  * - Terraform Provider `AWS <https://registry.terraform.io/providers/hashicorp/aws/latest/docs>`_
    - 5.35
  * - Terraform Provider `Local <https://registry.terraform.io/providers/hashicorp/local/latest/docs>`_
    - ~> 2.4
  * - Terraform Provider `Random <https://registry.terraform.io/providers/hashicorp/random/latest/docs>`_
    - ~> 3.6
  * - `terraform-aws-modules/acm <https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest>`_
    - 5.0
  * - `terraform-aws-modules/cloudfront <https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest>`_
    - 3.2
  * - `terraform-aws-modules/eks <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_
    - 20.0
  * - `terraform-aws-modules/iam <https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest>`_
    - ~> 5.9
  * - `terraform-aws-modules/rds <https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest>`_
    - 6.4
  * - `terraform-aws-modules/s3-bucket <https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest>`_
    - 3.15
  * - `terraform-aws-modules/security-group <https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest>`_
    - 5.1
  * - `terraform-aws-modules/vpc <https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest>`_
    - 5.5
  * - `Helm cert-manager <https://charts.jetstack.io>`_
    - 1.12
  * - `Helm Ingress Nginx Controller <https://kubernetes.github.io/ingress-nginx/>`_
    - 4.9
  * - `Helm Vertical Pod Autoscaler <https://github.com/cowboysysop/charts/tree/master/charts/vertical-pod-autoscaler>`_
    - 9.6
  * - `Helm Kubernetes Dashboard <https://kubernetes.github.io/dashboard/>`_
    - 6.0
  * - `Helm kubecost <https://kubecost.github.io/cost-analyzer/>`_
    - 2.0
  * - `Helm kubeapps <https://bitnami.com/stack/kubeapps/helm>`_
    - 14.3
  * - `Helm Karpenter <https://artifacthub.io/packages/helm/karpenter/karpenter>`_
    - 0.16
  * - `Helm Metrics Server <https://kubernetes-sigs.github.io/metrics-server/>`_
    - 3.11
  * - `Helm Prometheus <https://prometheus-community.github.io/helm-charts/>`_
    - 56.6.0
  * - `Helm Wordpress <https://charts.bitnami.com/bitnami/wordpress>`_
    - ~> 19.0
  * - `Helm phpMyAdmin <https://charts.bitnami.com/bitnami/phpmyadmin>`_
    - ~> 13.1
  * - `openedx-actions/tutor-k8s-init <https://github.com/marketplace/actions/open-edx-tutor-k8s-init>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-edx-secret <https://github.com/openedx-actions/tutor-k8s-configure-edx-secret>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-edx-admin <https://github.com/openedx-actions/tutor-k8s-configure-edx-admin>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-jwt <https://github.com/openedx-actions/tutor-k8s-configure-jwt>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-mysql <https://github.com/openedx-actions/tutor-k8s-configure-mysql>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-mongodb <https://github.com/openedx-actions/tutor-k8s-configure-mongodb>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-redis <https://github.com/openedx-actions/tutor-k8s-configure-redis>`_
    - v1
  * - `openedx-actions/tutor-k8s-configure-smtp <https://github.com/openedx-actions/tutor-k8s-configure-smtp>`_
    - v1
  * - `openedx-actions/tutor-print-dump <https://github.com/openedx-actions/tutor-print-dump>`_
    - v1
  * - `openedx-actions/tutor-plugin-build-backup <https://github.com/openedx-actions/tutor-plugin-build-backup>`_
    - v0
  * - `openedx-actions/tutor-plugin-build-credentials <https://github.com/openedx-actions/tutor-plugin-build-credentials>`_
    - v1
  * - `openedx-actions/tutor-plugin-build-license-manager <https://github.com/openedx-actions/tutor-plugin-build-license-manager>`_
    - v0
  * - `openedx-actions/tutor-plugin-build-openedx <https://github.com/openedx-actions/tutor-plugin-build-openedx>`_
    - v1
  * - `openedx-actions/tutor-plugin-build-openedx-add-requirement <https://github.com/openedx-actions/tutor-plugin-build-openedx-add-requirement>`_
    - v1
  * - `openedx-actions/tutor-plugin-build-openedx-add-theme <https://github.com/openedx-actions/tutor-plugin-build-openedx-add-theme>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-backup <https://github.com/openedx-actions/tutor-plugin-enable-backup>`_
    - v0
  * - `openedx-actions/tutor-plugin-enable-credentials <https://github.com/openedx-actions/tutor-plugin-enable-credentials>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-discovery <https://github.com/openedx-actions/tutor-plugin-enable-discovery>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-ecommerce <https://github.com/openedx-actions/tutor-plugin-enable-ecommerce>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-forum <https://github.com/openedx-actions/tutor-plugin-enable-forum>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-k8s-deploy-tasks <https://github.com/openedx-actions/tutor-plugin-enable-k8s-deploy-tasks>`_
    - v1
  * - `openedx-actions/tutor-enable-plugin-license-manager <https://github.com/openedx-actions/tutor-enable-plugin-license-manager>`_
    - v0
  * - `openedx-actions/tutor-plugin-enable-notes <https://github.com/openedx-actions/tutor-plugin-enable-notes>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-s3 <https://github.com/openedx-actions/tutor-plugin-enable-s3>`_
    - v1
  * - `openedx-actions/tutor-plugin-enable-xqueue <https://github.com/openedx-actions/tutor-plugin-enable-xqueue>`_
    - v1
