region   = "us-east-1"
name     = "interview-dev"
vpc_cidr = "10.10.0.0/16"

db_username = "appuser"
db_password = "ChangeMe-Use-SecretsManager"

tags = {
  Environment = "dev"
  Project     = "aws-interview-platform"
  Owner       = "you"
  CostCenter  = "learning"
}