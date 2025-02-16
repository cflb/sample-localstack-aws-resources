variable "region" {
    default = "us-east-1" 
}

variable "access_key" {
  default = "test"
}

variable "secret_key" {
  default = "test"
}

variable "endpoints" {
  default = "http://localhost:4566"
}

variable "s3_endpoints" {
  default = "http://s3.localhost:4566"
}

variable "dinamo_db_name" {
  default = "desafio-tfstate-storage"
}

variable "public_s3_bucket_name" {
  default = "bucket-for-storage"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "cidr_public_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}


variable "az_list" {
  description = "A list of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "route53_domain" {
  description = "Nome do domínio a ser configurado no Route53"
  type        = string
  default     = "meudominio.local"
}