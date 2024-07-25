variable "secret_name" {
  type        = string
  description = "The name of the secret"
}

variable "services" {
  type        = list(string)
  description = "The services to attach the policies to"
}
