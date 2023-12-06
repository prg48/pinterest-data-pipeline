from airflow import DAG
from airflow.providers.databricks.operators.databricks import DatabricksSubmitRunOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'Prabin',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 4,
    'retry_delay': timedelta(minutes=1)
}

with DAG("batch_processing_dag",
    start_date=datetime(year=2023, month=11, day=1),
    schedule_interval='@daily',
    catchup=False,
    default_args=default_args) as dag:

    # task to load batch data from S3 and save as delta table for faster reading
    load_data_from_S3_and_save_as_delta_tables = DatabricksSubmitRunOperator(
        task_id="load_data_from_S3_and_save_as_delta_tables",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1108-162752-8okw8dgg",
        notebook_task={
            "notebook_path":"/Users/prabingurung2@gmail.com/load_data_from_S3_and_save_as_delta_tables"
        }
    )

    # clean geo data and save it as delta table
    clean_geo_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_geo_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1108-162752-8okw8dgg",
        notebook_task={
            "notebook_path":"/Users/prabingurung2@gmail.com/clean_df_geo"
        }
    )

    # clean pin data and save it as delta table
    clean_pin_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_pin_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1108-162752-8okw8dgg",
        notebook_task={
            "notebook_path":"/Users/prabingurung2@gmail.com/clean_df_pin"
        }
    )

    # clean user data and save it as delta table
    clean_user_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_user_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="1108-162752-8okw8dgg",
        notebook_task={
            "notebook_path":"/Users/prabingurung2@gmail.com/clean_df_user"
        }
    )    

    # dag sequence
    load_data_from_S3_and_save_as_delta_tables
    load_data_from_S3_and_save_as_delta_tables >> clean_geo_data_and_save_as_delta_table
    load_data_from_S3_and_save_as_delta_tables >> clean_pin_data_and_save_as_delta_table
    load_data_from_S3_and_save_as_delta_tables >> clean_user_data_and_save_as_delta_table