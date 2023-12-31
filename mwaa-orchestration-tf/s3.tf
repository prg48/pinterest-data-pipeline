# create a s3 storage for dag
module "s3" {
  source = "../modules/s3"
  bucket_name = var.dag_storage
  bucket_environment_name = "dev"
  force_destroy = true
  block_public_access = true
  enable_bucket_versioning = true
}

# add the requirements.txt file to the dag storage
resource "aws_s3_object" "requirements" {
  bucket = module.s3.bucket_name
  key = "requirements.txt"
  source = "${path.root}/requirements.txt"
}

# add the dags to the dag storage
resource "aws_s3_object" "dags" {
  bucket = module.s3.bucket_name
  key = "dags/batch_processing_dag.py"
  source = "${path.root}/dags/batch_processing_dag.py"
}