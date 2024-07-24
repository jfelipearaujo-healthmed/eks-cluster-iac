variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of Kubernetes to use for the EKS cluster"
}

variable "cluster_endpoint" {
  type        = string
  description = "The endpoint for the EKS cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC provider for the EKS cluster"
}
