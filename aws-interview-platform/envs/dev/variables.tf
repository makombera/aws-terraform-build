variable "region" { type = string }

variable "name" { type = string }

variable "vpc_cidr" { type = string }

variable "db_username" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}