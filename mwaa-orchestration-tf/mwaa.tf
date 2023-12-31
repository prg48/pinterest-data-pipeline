# mwaa environment
module "mwaa" {
  source = "cloudposse/mwaa/aws"
  version = "0.6.0"

  region = var.region
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  delimiter = "_"
  airflow_version = "2.7.2"
  environment_class = "mw1.small"
  min_workers = 1
  max_workers = 2
  webserver_access_mode = "PUBLIC_ONLY"

  airflow_configuration_options = {
    # "core.load_default_connections" = "false"
    "core.load_examples" = "false"
    "webserver.dag_default_view" = "tree"
    "celery.pool" = "solo"
  }

  allow_all_egress = true
  create_s3_bucket = false
  source_bucket_arn = module.s3.bucket_arn
  dag_s3_path = "dags/"
  requirements_s3_path = "requirements.txt"

  dag_processing_logs_enabled = true
  dag_processing_logs_level = "INFO"
  scheduler_logs_enabled = true
  scheduler_logs_level = "INFO"
  webserver_logs_enabled = true
  webserver_logs_level = "INFO"
  worker_logs_enabled = true
  worker_logs_level = "INFO"
  task_logs_enabled = true
  task_logs_level = "INFO"

  context = module.this.context
}