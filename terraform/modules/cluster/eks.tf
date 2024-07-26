module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.5.2"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  create_cloudwatch_log_group    = false

  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_groups = {
    group = {
      name           = "workers"
      instance_types = ["t3.large"]

      min_size     = 1
      max_size     = 15
      desired_size = 1
    }
  }
}

resource "aws_iam_role" "service_account_role" {
  for_each = { for ns in var.namespaces : ns => ns }

  name = "${each.value}-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:ns-${each.value}:sa-${each.value}"
          }
        }
      },
    ]
  })
}

# module "fargate_profile" {
#   source  = "terraform-aws-modules/eks/aws//modules/fargate-profile"
#   version = "20.5.2"

#   name         = "apps-fargate-profile"
#   cluster_name = module.eks.cluster_name

#   subnet_ids = var.private_subnets

#   selectors = [{
#     namespace = "ns-products-ec2"
#   }]

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }
