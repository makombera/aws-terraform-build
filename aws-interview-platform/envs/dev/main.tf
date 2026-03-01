module "networking" {
  source   = "../../modules/networking"
  name     = var.name
  vpc_cidr = var.vpc_cidr
  az_count = 2
}
#
# todo: add RDS module here
module "database" {
  source              = "../../modules/database"
  name                = var.name
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  db_username         = var.db_username
  db_password         = var.db_password
  db_instance_class   = "db.t4g.micro"
  deletion_protection = false
}

module "storage_lambda" {
  source = "../../modules/storage_lambda"
  name   = var.name
  vpc_id = module.networking.vpc_id
}

module "ecs_app" {
  source              = "../../modules/ecs_app"
  name                = var.name
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  private_subnet_ids  = module.networking.private_subnet_ids
  db_endpoint         = module.database.db_endpoint
  uploads_bucket_name = module.storage_lambda.uploads_bucket_name
}

module "observability" {
  source                  = "../../modules/observability"
  name                    = var.name
  alb_arn_suffix          = module.ecs_app.alb_arn_suffix
  target_group_arn_suffix = module.ecs_app.target_group_arn_suffix
  ecs_service_name        = module.ecs_app.ecs_service_name
  ecs_cluster_name        = module.ecs_app.ecs_cluster_name
}