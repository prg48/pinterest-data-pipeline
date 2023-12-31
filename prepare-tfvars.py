"""
prepare-tfvars.py

Purpose:
    This script checks if the 'config.yml' file has valid configurations and prepares terraform.tfvars files 
    for multiple Terraform directories ('batch-ingestion-tf', 'databricks-tf', 'main-storage-s3-tf', 
    'mwaa-orchestration-tf', and 'stream-ingestion-tf'). It compiles a unified 'config.yml', where the user 
    enters variables only once, and then prepares terraform.tfvars for all specified folders. This approach 
    ensures consistency and efficiency in managing variables like s3_bucket_name, aws_region, etc., that are 
    common across different Terraform configurations.

Usage:
    python prepare-tfvars.py

    Ensure that 'config.yml' is present in the same directory as this script and contains all the necessary 
    configuration values. The script validates the configuration and then generates terraform.tfvars for 
    each specified Terraform directory.

Custom Exceptions:
    ConfigMissingError: Raised when a required configuration key is missing from the config file.
    ConfigValueTypeMismatchError: Raised when the type of a configuration value does not match the expected type (e.g., not a string).

Notes:
    - The script assumes that all necessary AWS and Databricks configurations are provided in 'config.yml'.
    - The script does not handle all possible errors and edge cases.
"""



import yaml

class ConfigMissingError(Exception):
    """Exception to be raised when a config is missing"""
    def __init__(self, config, message="Missing config: "):
        self.config = config
        self.message = message
        super().__init__(f"{message} {config}")

class ConfigValueTypeMismatchError(Exception):
    """Exception to be raise when a config value type mismatches"""
    def __init__(self, value_type, intended_type, config, message="Value type mismatch: "):
        self.value_type = value_type
        self.intended_type = intended_type
        self.config = config
        self.message = message
        super().__init__(f"{message} value entered for {config} is of type {value_type}, should be of type {intended_type}")

def validate_yml_config(config: dict) -> bool:
    """
    Validates the yaml configuration.

    Args:
        config (dict): the dictionary of the configuration 

    Returns:
        bool : True if the configuration is valid else prints Exception
    """
    try:
        if validate_config_keys(config=config) and validate_config_value_types(config=config):
            return True
    except Exception as e:
        print(e)

def validate_config_value_types(config: dict) -> bool:
    """
    Validates the type of the values for the config

    Args:
        config (dict): dictionary of the configuration

    Returns:
        bool : True if the values for the config dictionary is valid

    Raises:
        ConfigValueTypeMismatchError : if the values for the config dictionary is not valid
    """
    for key in config.keys():
        for subkey in config[key].keys():
            value_type = type(config[key][subkey])
            if not value_type is str:
                raise ConfigValueTypeMismatchError(value_type=value_type, intended_type=str, config=f"{key}.{subkey}")
            
    return True

def validate_config_keys(config: dict) -> bool:
    """
    Validates the keys for the config

    Args:
        config (dict): dictionary of the configuration

    Returns:
        bool : True if the config keys are valid

    Raises:
        ConfigMissingError : if the keys for the config are not valid
    """
    valid_config_keys = ["aws", "databricks", "s3_storage"]
    valid_config_subkeys_dict = {
        "aws": ["region", "access_key", "secret_key"],
        "databricks": ["account_id", "client_id", "client_secret", "workspace_name"],
        "s3_storage": ["main_processing_data_storage_name", "databricks_root_storage_name", "mwaa_dag_storage_name"],
        "mwaa": ["mwaa_env_name"]
    }

    for key in valid_config_keys:
        if key not in config.keys():
            raise ConfigMissingError(config=key)

        for subkey in valid_config_subkeys_dict[key]:
            if subkey not in config[key].keys():
                raise ConfigMissingError(config=f"{key}.{subkey}")
            
    return True

            

def open_yaml_config_file(filename: str) -> dict:
    """
    Opens a yaml file and returns its contents

    Args:
        filename (str): file to open and read
    
    Returns:
        dict: dictionary of the yaml filename contents
    """
    with open(filename, "r") as file:
        try:
            config = yaml.safe_load(file)
            return config
        except yaml.YAMLError as e:
            print(f"Some error occured: {e}")

def tfvars_decorator(directory):
    """
    A decorator for functions that prepare and write terraform.tfvars files.

    This decorator adds common functionality to various tfvars preparation functions.
    It prints out a message indicating the start and completion of the tfvars preparation,
    and writes the resulting tfvars string to a file in the specified directory.

    Args:
        directory (str): The directory name where the terraform.tfvars file will be written.

    Returns:
        A wrapper function that takes a configuration dictionary, calls the decorated
        tfvars preparation function to get the tfvars string, and writes it to the
        appropriate terraform.tfvars file within the specified directory.
    """
    def decorator(func):
        def wrapper(config):
            print(f"Preparing terraform.tfvars for '{directory}'")
            
            # Get the tfvars string from the function
            tfvars_string = func(config)
            
            # Write the tfvars string to the appropriate file
            with open(f"{directory}/terraform.tfvars", "w") as file:
                file.write(tfvars_string)
            
            print(f"terraform.tfvars file written in '{directory}/terraform.tfvars'\n")
        return wrapper
    return decorator


@tfvars_decorator("batch-ingestion-tf")
def prepare_tfvars_batch_ingestion_tf(config: dict) -> str:
    """
    Returns the tfvars string for 'batch-ingestion-tf'

    Args:
        config (dict) : The configuration file

    Returns:
        str : The tfvars string
    """
    tfvars_string = f"""region="{config["aws"]["region"]}"
bucket_name="{config['s3_storage']['main_processing_data_storage_name']}"
"""
    return tfvars_string


@tfvars_decorator("main-storage-s3-tf")
def prepare_tfvars_main_storage_s3_tf(config: dict) -> str:
    """
    Returns the tfvars string for 'main-storage-s3-tf'

    Args:
        config (dict) : The configuration file

    Returns:
        str : The tfvars string
    """
    tfvars_string = f"""bucket_name="{config['s3_storage']['main_processing_data_storage_name']}"
"""
    return tfvars_string

@tfvars_decorator("mwaa-orchestration-tf")
def prepare_tfvars_mwaa_orchestration_tf(config: dict) -> str:
    """
    Returns the tfvars string for 'mwaa-orchestration-tf'

    Args:
        config (dict) : The configuration file

    Returns:
        str : The tfvars string
    """
    tfvars_string = f"""dag_storage="{config['s3_storage']['mwaa_dag_storage_name']}"
region="{config['aws']['region']}"
mwaa_env_name="{config['mwaa']['mwaa_env_name']}"
"""
    return tfvars_string

@tfvars_decorator("stream-ingestion-tf")
def prepare_tfvars_stream_ingestion_tf(config: dict) -> str:
    """
    Returns the tfvars string for 'stream-ingestion-tf'

    Args:
        config (dict) : The configuration file

    Returns:
        str : The tfvars string
    """
    tfvars_string = f"""region="{config['aws']['region']}"
"""
    return tfvars_string

@tfvars_decorator("databricks-tf")
def prepare_tfvars_databricks_tf(config: dict) -> str:
    """
    Returns the tfvars string for 'databricks-tf'

    Args:
        config (dict) : The configuration file

    Returns:
        str : The tfvars string
    """
    tfvars_string = f"""region="{config['aws']['region']}"
databricks_account_id="{config['databricks']['account_id']}"
databricks_client_id="{config['databricks']['client_id']}"
databricks_client_secret="{config['databricks']['client_secret']}"
databricks_root_bucket_name="{config['s3_storage']['databricks_root_storage_name']}"
workspace_name="{config['databricks']['workspace_name']}"
aws_access_key_id="{config['aws']['access_key']}"
aws_secret_access_key="{config['aws']['secret_key']}"
s3_mount_bucket_name="{config['s3_storage']['main_processing_data_storage_name']}"
"""
    return tfvars_string


if __name__=="__main__":
    filename = "config.yml"
    config = open_yaml_config_file(filename=filename)
    if validate_yml_config(config=config):
        prepare_tfvars_batch_ingestion_tf(config=config)
        prepare_tfvars_main_storage_s3_tf(config=config)
        prepare_tfvars_mwaa_orchestration_tf(config=config)
        prepare_tfvars_stream_ingestion_tf(config=config)
        prepare_tfvars_databricks_tf(config=config)