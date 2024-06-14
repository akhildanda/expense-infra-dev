variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
    Component = "app-alb"
  }
}

variable "zone_name" {
  default = "akhildev.online"
}

variable "zone_id" {
  default = "Z0895514WYXV2A6F4ZOI"
}