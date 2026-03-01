terraform {
  backend "s3" {
    bucket       = "makombera-org-backend"
    key          = "aws-interview-platform/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}