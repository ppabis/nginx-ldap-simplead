variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "directory_name" {
  description = "The fully qualified name for the directory, such as corp.example.com"
  type        = string
}
