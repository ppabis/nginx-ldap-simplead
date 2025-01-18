variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "directory_name" {
  description = "The fully qualified name for the directory, such as corp.example.com"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR block for SSH and RDP access"
  type        = string
}
variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

