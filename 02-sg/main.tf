module "db" {
 source = "../../terraform-aws-securitygroup"
 project_name = var.project_name
 environment = var.environment
 sg_description = "SG for db MySQL Instances"
 vpc_id  = data.aws_ssm_parameter.vpc_id.value
 common_tags = var.common_tags
 sg_name = "db"
}

module "backend" {
 source = "../../terraform-aws-securitygroup"
 project_name = var.project_name
 environment = var.environment
 sg_description = "SG for Backend Instances"
 vpc_id  = data.aws_ssm_parameter.vpc_id.value
 common_tags = var.common_tags
 sg_name = "backend"
}

module "frontend" {
 source = "../../terraform-aws-securitygroup"
 project_name = var.project_name
 environment = var.environment
 sg_description = "SG for Frontend Instances"
 vpc_id  = data.aws_ssm_parameter.vpc_id.value
 common_tags = var.common_tags
 sg_name = "frontend"
}

module "bastion" {
 source = "../../terraform-aws-securitygroup"
 project_name = var.project_name
 environment = var.environment
 sg_description = "SG for Bastion Instances"
 vpc_id  = data.aws_ssm_parameter.vpc_id.value
 common_tags = var.common_tags
 sg_name = "bastion"
}

module "app-alb" {
 source = "../../terraform-aws-securitygroup"
 project_name = var.project_name
 environment = var.environment
 sg_description = "SG for APP ALB Instances"
 vpc_id  = data.aws_ssm_parameter.vpc_id.value
 common_tags = var.common_tags
 sg_name = "app-alb"
}

module "vpn" {
 source = "../../terraform-aws-securitygroup"
 project_name = var.project_name
 environment = var.environment
 sg_description = "SG for VPN Instances"
 vpc_id  = data.aws_ssm_parameter.vpc_id.value
 common_tags = var.common_tags
 sg_name = "vpn"
 ingress_rules = var.vpn_sg_rules
}

# DB is accepting connections from backend 
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id
  security_group_id = module.db.sg_id
}

# DB is accepting connections from bastion
resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.db.sg_id
}

# DB is accepting connections from vpn
resource "aws_security_group_rule" "db_vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.db.sg_id
}

# Backend is accepting connections from app-alb
resource "aws_security_group_rule" "backend_app-alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app-alb.sg_id
  security_group_id = module.backend.sg_id
}

# Backend is accepting connections from bastion
resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

# Backend is accepting connections from vpn-ssh
resource "aws_security_group_rule" "backend_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend.sg_id
}

# Backend is accepting connections from vpn-http
resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend.sg_id
}

# Frontend is accepting connections from public(internet)
resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = module.frontend.sg_id
}

# Frontend is accepting connections from bastion
resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

# Frontend is accepting connections from public
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = module.bastion.sg_id
}

resource "aws_security_group_rule" "app-alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id 
  security_group_id = module.app-alb.sg_id
}

resource "aws_security_group_rule" "app-alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id 
  security_group_id = module.app-alb.sg_id
}

