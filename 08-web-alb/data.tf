data "aws_ssm_parameter" "web-alb_sg_id" {
    name = "/${var.project_name}/${var.environment}/web-alb_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/${var.project_name}/${var.environment}/acm_certificate_arn"
}


   