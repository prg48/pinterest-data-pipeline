"""
prepare-dag.py

Purpose:
    This script dynamically prepares an Airflow DAG for the Amazon Managed Workflows for Apache Airflow (MWAA) environment. 
    It utilizes the cluster ID generated in the 'databricks-tf' directory and the paths of the notebooks uploaded to the 
    Databricks workspace. The script automates the process of integrating Databricks notebook paths into the MWAA DAG, 
    simplifying the setup and maintenance of the workflow. This automation ensures that users do not need to manually 
    search for and configure notebook paths, thereby reducing errors and streamlining deployments in the MWAA environment.

Usage:
    python prepare-dag.py

    Before running the script, ensure that the Databricks architecture is already set up in the 'databricks-tf' directory. 
    The Terraform configuration in 'databricks-tf' should output the necessary cluster ID and notebook paths file. These 
    outputs are essential for the script to dynamically set up the notebook paths in the DAG.

    The script will generate a 'batch_processing_dag.py' file, which should be placed in the dags directory.

Custom Exceptions:
    PathNotFoundError: Raised when a specified path in the notebook_paths is not found. This exception ensures that the 
    script only proceeds if all necessary notebook paths are correctly identified, preventing misconfigurations in the 
    generated DAG.

Notes:
    - The script is part of a larger workflow and assumes a specific project structure and naming conventions as 
      established in the 'databricks-tf' directory.
    - Ensure that the 'databricks-tf' directory contains the latest and correct Terraform outputs before running this script.
    - The script also should be run before setting up the mwaa environment as it prepares the dag required to orchestrate batch processing.

"""

from pathlib import Path

class PathNotFoundError(Exception):
    """Exception to be raise when the path is not found in the list"""
    def __init__(self, key, message="Path not found for key:"):
        self.key = key
        self.message = message
        super().__init__(f"{message} {key}")

def read_file_contents(filename: str) -> list[str]:
    """
    Reads the contents of a file

    Args:
        filename (str): the file to read the contents of
    
    Returns:
        list[str]: list of file contents
    """
    try:
        with open(filename, "r") as file:
            lines = [line.strip() for line in file]
            return lines
        
    except FileNotFoundError as e:
        print(f"Cannot find the file, '{filename}'")

    except Exception as e:
        print(f"Some error occured: {e}")


def get_notebook_path(notebook_paths: list[str], key: str) -> str:
    """
    Returns the path from the list of notebook_paths which matches the key

    Args:
        notebook_paths (list[str]): list of paths
        key (str): key to look for in list of paths

    Returns:
        str: the path that matches the key

    Raises:
        PathNotFoundError: if no path that matches the key in notebook_paths
    """
    for path in notebook_paths:
        if key in path:
            return path
    
    raise PathNotFoundError(key)
    

def get_dag_notebook_paths(filename: str) -> dict:
    """
    computes the path for all notebooks and assigns it to relevant keys in a dictionary

    Args:
        filename (str): the file to read the contents and get the paths

    Returns:
        dict: dictionary of paths for all notebooks with relevant keys
    """
    script_path = Path(__file__).parent
    filepath = script_path / f"{filename}"

    notebook_map = {
        "mount_s3_storage": "",
        "load_data_from_S3_and_save_as_delta_table": "",
        "clean_df_geo": "",
        "clean_df_pin": "",
        "clean_df_user": ""
    }

    notebook_paths = read_file_contents(filepath)
    
    for key in notebook_map.keys():
        try:
            notebook_map[key] = get_notebook_path(notebook_paths, key)
        
        except PathNotFoundError:
            print("Path not found for {key}")

    return notebook_map

def main():
    print("Preparing dag")
    notebook_paths = get_dag_notebook_paths("../databricks-tf/batch-processing-notebook-paths.txt")
    cluster_id = read_file_contents("../databricks-tf/cluster-id.txt")[0]
    dag_file = "dags/batch_processing_dag.py"

    dag_string = f"""from airflow import DAG
from airflow.providers.databricks.operators.databricks import DatabricksSubmitRunOperator
from datetime import datetime, timedelta

default_args = {{
    'owner': 'Name',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 4,
    'retry_delay': timedelta(minutes=1)
}}

with DAG("batch_processing_dag",
    start_date=datetime(year=2023, month=11, day=1),
    schedule_interval=None,
    catchup=False,
    default_args=default_args) as dag:

    # task to mount the s3 bucket in databricks
    mount_s3_storage = DatabricksSubmitRunOperator(
        task_id="mount_s3_bucket",
        databricks_conn_id="databricks_default",
        existing_cluster_id="{cluster_id}",
        notebook_task={{
            "notebook_path":"{notebook_paths['mount_s3_storage']}"
        }}
    )

    # task to load batch data from S3 and save as delta table for faster reading
    load_data_from_S3_and_save_as_delta_tables = DatabricksSubmitRunOperator(
        task_id="load_data_from_S3_and_save_as_delta_tables",
        databricks_conn_id="databricks_default",
        existing_cluster_id="{cluster_id}",
        notebook_task={{
            "notebook_path":"{notebook_paths['load_data_from_S3_and_save_as_delta_table']}"
        }}
    )

    # clean geo data and save it as delta table
    clean_geo_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_geo_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="{cluster_id}",
        notebook_task={{
            "notebook_path":"{notebook_paths['clean_df_geo']}"
        }}
    )

    # clean pin data and save it as delta table
    clean_pin_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_pin_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="{cluster_id}",
        notebook_task={{
            "notebook_path":"{notebook_paths['clean_df_pin']}"
        }}
    )

    # clean user data and save it as delta table
    clean_user_data_and_save_as_delta_table = DatabricksSubmitRunOperator(
        task_id="clean_user_data_and_save_as_delta_table",
        databricks_conn_id="databricks_default",
        existing_cluster_id="{cluster_id}",
        notebook_task={{
            "notebook_path":"{notebook_paths['clean_df_user']}"
        }}
    )    

    # dag sequence
    mount_s3_storage
    mount_s3_storage >> load_data_from_S3_and_save_as_delta_tables
    load_data_from_S3_and_save_as_delta_tables >> clean_geo_data_and_save_as_delta_table
    load_data_from_S3_and_save_as_delta_tables >> clean_pin_data_and_save_as_delta_table
    load_data_from_S3_and_save_as_delta_tables >> clean_user_data_and_save_as_delta_table
    """

    with open(dag_file, "w") as file:
        file.write(dag_string)
    
    print(f"dag written in {dag_file}")

if __name__ == "__main__":
    main()