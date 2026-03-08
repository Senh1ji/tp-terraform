variable "aws_region" {
  description = "Région AWS"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC existant"
  type        = string
}

variable "subnet_public_cidr" {
  description = "CIDR du subnet public (frontend)"
  type        = string
}

variable "subnet_private_cidr" {
  description = "CIDR du subnet privé (backend)"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
}
