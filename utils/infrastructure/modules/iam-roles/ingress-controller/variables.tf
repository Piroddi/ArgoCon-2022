variable "ingress-controller-service-accounts" {
  type        = list(string)
  description = "Kubernetes service accounts who are allowed to assume this AWS role"
}

variable "oidc_provider_arn" {
  type        = string
  description = "The EKS OIDC provider for the cluster where Argo will be deployed on. This is required for IRSA"
}

variable "oidc_provider_url" {
  type        = string
  description = "The EKS OIDC provider for the cluster where Argo will be deployed on. This is required for IRSA"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to add to all role resources"
}