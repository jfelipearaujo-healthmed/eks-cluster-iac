module "network" {
  source = "./modules/network"

  cluster_name = var.cluster_name
  region       = var.region

  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

module "cluster" {
  source = "./modules/cluster"

  region = var.region

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  namespaces = [
    "users",
    "scheduler",
    "review-processor",
    "appointments",
    "appointment-creator",
  ]

  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
}

module "secret" {
  source = "./modules/secret"

  secret_name = "jwt-signing-key"

  services = [
    "users",
    "scheduler",
    "review-processor",
    "appointments",
    "appointment-creator",
  ]

  depends_on = [
    module.cluster,
    module.network
  ]
}

module "addon" {
  source = "./modules/addon"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id   = module.network.vpc_id
  vpc_cidr = var.vpc_cidr

  cluster_endpoint  = module.cluster.cluster_endpoint
  oidc_provider_arn = module.cluster.oidc_provider_arn

  depends_on = [
    module.cluster,
    module.network
  ]
}

resource "helm_release" "csi-secrets-store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"

  # Optional Values
  # https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html#optional-values
  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
  set {
    name  = "enableSecretRotation"
    value = "true"
  }

  depends_on = [
    module.cluster,
    module.addon
  ]
}

resource "helm_release" "secrets-provider-aws" {
  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"

  depends_on = [
    module.cluster,
    module.addon,
    helm_release.csi-secrets-store
  ]
}
