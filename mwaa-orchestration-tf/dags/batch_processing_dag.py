from airflow import DAG
from airflow.providers.databricks.operators.databricks import DatabricksSubmitRunOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'Name',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 4,
    'retry_delay': timedelta(minutes=1)
}

with DAG("batch_processing_dag",
    start_date=datetime(year=2023, month=11, day=1),
    schedule_interval=None,
    catchup=False,
    default_args=default_args) as dag:

    # task to mount the s3 bucket in databricks
    mount_s3_storage = DatabricksSubmitRunOperator(
        task_id="mount_s3_bucket",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1231-072534-fz9rdf4g",
        notebook_task={
            "notebook_path":"/Users/ca706895-8dd1-4e70-8a04-e3078422f7f8/mount_s3_storage.ipynb"
        }
    )

    # task to load batch data from S3 and save as delta table for faster reading
    load_data_from_S3_and_save_as_delta_tables = DatabricksSubmitRunOperator(
        task_id="load_data_from_S3_and_save_as_delta_tables",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1231-072534-fz9rdf4g",
        notebook_task={
            "notebook_path":"/Users/ca706895-8dd1-4e70-8a04-e3078422f7f8/load_data_from_S3_and_save_as_delta_tables.ipynb"
        }
    )

    # clean geo data and save it as delta table
    clean_geo_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_geo_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1231-072534-fz9rdf4g",
        notebook_task={
            "notebook_path":"/Users/ca706895-8dd1-4e70-8a04-e3078422f7f8/clean_df_geo.ipynb"
        }
    )

    # clean pin data and save it as delta table
    clean_pin_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_pin_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1231-072534-fz9rdf4g",
        notebook_task={
            "notebook_path":"/Users/ca706895-8dd1-4e70-8a04-e3078422f7f8/clean_df_pin.ipynb"
        }
    )

    # clean user data and save it as delta table
    clean_user_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_user_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1231-072534-fz9rdf4g",
        notebook_task={
            "notebook_path":"/Users/ca706895-8dd1-4e70-8a04-e3078422f7f8/clean_df_user.ipynb"
        }
    )    

    # dag sequence
    mount_s3_storage
    mount_s3_storage >> load_data_from_S3_and_save_as_delta_tables
    load_data_from_S3_and_save_as_delta_tables >> clean_geo_data_and_save_as_delta_table
    load_data_from_S3_and_save_as_delta_tables >> clean_pin_data_and_save_as_delta_table
    load_data_from_S3_and_save_as_delta_tables >> clean_user_data_and_save_as_delta_table
    