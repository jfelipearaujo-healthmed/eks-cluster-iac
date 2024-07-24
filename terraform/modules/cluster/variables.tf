variable "region" {
  type        = string
  description = "The default region to use for AWS"
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of Kubernetes to use for the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "The IDs of the private subnets"
}

variable "namespaces" {
  type        = list(string)
  description = "The list of namespaces to create the roles for service account"
}
