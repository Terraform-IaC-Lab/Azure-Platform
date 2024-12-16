variable "service_principal_names" {
  description = "List of service principal names to create"
  type        = list(string)
}

variable "location" {
  default     = "westeurope"
  description = "Azure region where the Resource Group is created"
  type        = string
}
