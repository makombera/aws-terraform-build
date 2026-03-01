variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_username" { type = string }
#variable "db_password" { type = string "sensitive" = true }
variable "db_instance_class" { type = string }

variable "deletion_protection" {
  type    = bool
  #default = true
  default = false
}

variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "db" {
  name   = "${var.name}-db-sg"
  vpc_id = var.vpc_id

  # Inbound is added later by ecs_app SG rule (least privilege)
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.name}-postgres"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  username                = var.db_username
  password                = var.db_password
  #skip_final_snapshot     = true
  skip_final_snapshot     = false
  deletion_protection     = var.deletion_protection
  publicly_accessible     = false
}
output "db_endpoint" { value = aws_db_instance.this.address }
output "db_sg_id" { value = aws_security_group.db.id }