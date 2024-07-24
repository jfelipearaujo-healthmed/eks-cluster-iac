module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16"

  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  cluster_endpoint  = var.cluster_endpoint
  oidc_provider_arn = var.oidc_provider_arn

  enable_metrics_server               = true
  enable_aws_efs_csi_driver           = true
  enable_aws_load_balancer_controller = true
  enable_ingress_nginx                = true

  # ingress_nginx = {
  #   name = "nginx"
  #   values = [
  #     <<-EOT
  #         controller:
  #           replicaCount: 1
  #           service:
  #             annotations:
  #               service.beta.kubernetes.io/aws-load-balancer-name: nginx
  #               service.beta.kubernetes.io/aws-load-balancer-type: nlb
  #               service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  #               service.beta.kubernetes.io/aws-load-balancer-security-groups: ${aws_security_group.ingress_nginx_internal.id}
  #           service.beta.kubernetes.io/aws-load-balancer-security-groups: ${aws_security_group.ingress_nginx_internal.id}
  #             loadBalancerClass: service.k8s.aws/nlb
  #             loadBalancerClass: service.k8s.aws/nlb
  #           topologySpreadConstraints:
  #             - maxSkew: 1
  #               topologyKey: topology.kubernetes.io/zone
  #               whenUnsatisfiable: ScheduleAnyway
  #               labelSelector:
  #                 matchLabels:
  #                   app.kubernetes.io/instance: nginx
  #             - maxSkew: 1
  #               topologyKey: kubernetes.io/hostname
  #               whenUnsatisfiable: ScheduleAnyway
  #               labelSelector:
  #                 matchLabels:
  #                   app.kubernetes.io/instance: nginx
  #           minAvailable: 1
  #           ingressClassResource:
  #             name: nginx
  #             default: true
  #       EOT
  #   ]
  # }

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      before_compute           = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId",
        value = var.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
    ]
  }
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.37.1"

  role_name_prefix = "${var.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.37.1"

  role_name_prefix = "${var.cluster_name}-vpc-cni-"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

# resource "aws_security_group" "ingress_nginx_internal" {
#   name        = "ingress-nginx-internal"
#   description = "Allow local HTTP and HTTPS traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
