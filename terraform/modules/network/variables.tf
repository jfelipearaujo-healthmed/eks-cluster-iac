variable "region" {
  type        = string
  description = "The default region to use for AWS"
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "The availability zones to use for the VPC"
}
