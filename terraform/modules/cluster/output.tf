output "cluster" {
  description = "values for the EKS cluster"
  value       = module.eks
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  value       = module.eks.oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  description = "The certificate-authority-data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}
