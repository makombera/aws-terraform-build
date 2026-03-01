variable "name" { type = string }
variable "vpc_cidr" { type = string }
#variable "az_count" { type = number default = 2 }

variable "az_count" {
  type    = number
  default = 2
}