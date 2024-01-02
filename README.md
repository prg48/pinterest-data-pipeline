# Pinterest Data Pipeline &#x1F4CC;

This project, developed as part of the **AI Core Data Engineering Bootcamp**, showcases the creation of two data pipelines: a **batch-processing** data pipeline and a **stream-processing** data pipeline. Utilizing a variety of AWS services such as **API Gateway**, **Managed Services for Kafka (MSK)**, **S3**, **Databricks (Spark)**, and more, this project demonstrates comprehensive data ingestion, transformation, and storage processes. The pipelines are designed to handle sample Pinterest data on a user account on AWS, provided by the bootcamp, to produce **query-ready** data at the end of the pipeline. This endeavor serves as both a practical learning opportunity in various data engineering practices and technologies, and as a potential reference for those delving into the field.

> **Note: If you are setting up the project with Terraform on your own AWS account, please be aware that the project utilizes services that are not included in the free tier, such as MSK, MWAA, and Databricks. Consequently, you will incur some costs associated with these services.**

## Project Architecture

| ![pinterest architecture](/images/pinterest_architecture.jpeg) |
| :------------------------------------------------: |
| pinterest architecture                              |

## Table of Contents

### Requirements
|**Name** |**Version** |
|---------|------------|
|[python](https://www.python.org/downloads/)   |3.x         |
|[ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)  |>=2.9       |
|[conda/venv](https://lynn-kwong.medium.com/how-to-create-virtual-environments-with-venv-and-conda-in-python-31814c0a8ec2) | *        |
|[terraform](https://developer.hashicorp.com/terraform/install) | >=1.0.0   |
|[aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  | 2.x        |
|[aws account](https://aws.amazon.com/resources/create-account/) | -       |
|[databricks account (not community edition)](https://docs.databricks.com/en/getting-started/index.html) | - |

### Terraform providers
|**Name** | **Version** |
|---------|-------------|
|[aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)      | >=4.63.0    |
|[databricks](https://registry.terraform.io/providers/databricks/databricks/latest/docs) | -         |

### Cloning the project
To clone the project, ensure you have Git installed on your system. You can download Git from the [official Git page](https://git-scm.com/downloads). Use the following command to clone the project:

```bash
git clone https://github.com/prg48/pinterest-data-pipeline.git
```

### Project Structure
The project is organized into several Terraform directories, each responsible for managing its own state and variables. This modular approach ensures that each component is isolated, manageable, and scalable. Below is an overview of the project structure:

* [batch-ingestion-tf](/batch-ingestion-tf/): This directory is dedicated to setting up the infrastructure required for batch data ingestion. It includes the provisioning of resources such as the **API Gateway**, **Managed Services for Kafka (MSK) cluster**, **Kafka client**, and other associated services. Additionally, it manages the configuration of the Kafka client through Ansible.
* [main-storage-s3-tf](/main-storage-s3-tf/): Contains the Terraform scripts for the main S3 bucket, which is used for storing processing data and other associated files. This bucket acts as the central repository for all data handled by the pipelines.
* [stream-ingestion-tf](/stream-ingestion-tf/): Focuses on the infrastructure required for **stream data ingestion**. It provisions resources such as the **API Gateway** and **Kinesis Data Streams**, along with other necessary services to handle real-time data flow.
* [databricks-tf](/databricks-tf/): Handles the creation and configuration of the **Databricks workspace** and **cluster**. It also manages the transfer of notebooks from the local repository to the Databricks workspace.
* [mwaa-orchestration-tf](/mwaa-orchestration-tf/): Responsible for provisioning the **Managed Workflows for Apache Airflow (MWAA)** environment and its associated services. It includes script to dynamically prepare DAG according to the notebook paths in the Databricks workspace created by the [databricks-tf](/databricks-tf/) directory.
* [databricks-notebooks](/databricks-notebooks/): This directory contains the Databricks notebooks that will be uploaded to the Databricks workspace by the [databricks-tf](/databricks-tf/) directory.
* [emulation-scripts](/emulation-scripts/): Includes scripts to emulate producers for **Kafka** and **Kinesis Datastreams**.
* [modules](/modules/): Contains reusable Terraform modules for various components like **Databricks workspace provisioning**, **S3**, and **Kinesis Data Streams**.
* [images](/images/): Hosts images used in the [README.md](/README.md) documentation.
* [config.yml](/config.yml): The main configuration file for the project. It includes necessary parameters for **AWS**, **Databricks**, **S3 bucket** names, and **MWAA** environment settings.
* [prepare-tfvars.py](/prepare-tfvars.py): Script designed to prepare **terraform.tfvars** for each terraform directory based on the values supplied in [config.yml](/config.yml).
* [requirements.txt](/requirements.txt): Contains python requirements to run [emulation-scripts](/emulation-scripts/), [prepare-tfvars.py](/prepare-tfvars.py) etc.
* [README.md](/README.md): Documentation for the project.

### Preparing Terraform Variables (tfvars)
Each Terraform directory in this project requires specific variables to provision the related infrastructure. These variables are typically passed with a **terraform.tfvars** file in the respective directories, eliminating the need to manually enter each variable at Terraform runtime. The script [prepare-tfvars.py](/prepare-tfvars.py) is designed to automate this process by reading the values from [config.yml](/config.yml) and preparing **terraform.tfvars** for each Terraform directory. To facilitate this automation, AWS and Databricks credentials must be supplied to [config.yml](/config.yml) file. The credentials can be acquired as follows:

#### Getting AWS Access Keys and Configuring AWS CLI

To interact with AWS services, you'll need to [set up access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c) and [configure the AWS CLI](https://cloudacademy.com/blog/how-to-use-aws-cli/) with your credentials.

1. **Create or Use an Existing AWS User**: If you don't have a user, [create a new IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) user in your AWS account with administrative privileges. For existing users, ensure they have the necessary permissions to provision the resources required by this project.

2. **Generate Access Keys**: Once you have a user, [generate a new set of access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c) (access key ID and secret access key). These keys will be used to authenticate your requests to AWS.

3. **Update config.yml**: Enter the generated access key ID and secret access key in the respective fields (access_key and secret_key) in the [config.yml](/config.yml) file. This step is crucial as it allows Terraform to interact with AWS services under your account.

4. **Configure AWS CLI**: [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configure it](https://cloudacademy.com/blog/how-to-use-aws-cli/) if you haven't already using the **aws configure** command. Input your access key ID, secret access key, and default region when prompted. Ensure that the region matches the one specified in your [config.yml](/config.yml) file.

#### Getting Databricks Account Id and Service principal token

To automate interactions with Databricks for provisioning workspaces and clusters via Terraform, you'll need a [service principal](https://docs.databricks.com/en/dev-tools/service-principals.html) and your [databricks account ID](https://docs.databricks.com/en/administration-guide/account-settings/index.html#locate-your-account-id).

1. **Creating a Service Principal**: A service principal allows you to automate Databricks API interactions through IaC tools like Terraform. To create one:
    * Navigate to the **User management** tab in your Databricks account.
    * Select the **Service principals** tab, then click the **Add service principal** button and provide a name for it.
    * After creation, click on the service principal's name. Under the **Roles** tab, assign the **Account admin** role.
    * Go to the **Permissions** tab, click **Grant access**, and enter the service principal's name in the **User, Group or Service Principal** section. Assign the **Service Principal: User** role and save your changes.
    * Lastly, under the **Principal information** tab, click **Generate secret** to create an OAuth secret and Client ID. These credentials are used for authenticating the service principal. 

2. **Locating the account ID**: Your Databricks account ID is located at the top right corner of the Databricks console, accessible by clicking on your account email.

3. **Update config.yml**: Input the generated OAuth secret into the **client_secret** field, the OAuth client ID into the **client_id** field, and the account ID into the **account_id** field in your [config.yml](/config.yml) file. 

#### Finalizing Configuration and Preparing tfvars

To ensure smooth setup and execution of the Terraform scripts, follow these final steps to complete the configuration and prepare the **terraform.tfvars** files:

1. **Complete config.yml**: Complete the [config.yml](/config.yml) file with preferred S3 bucket names, databricks workspace name and mwaa environment name on addition to the **AWS** and **Databricks** credentials above. 

2. **Activate Virtual Environment**: [Set up  and activate virtual environment](https://lynn-kwong.medium.com/how-to-create-virtual-environments-with-venv-and-conda-in-python-31814c0a8ec2) using conda or virtualenv.

3. **Install Requirements**: With the virtual environment activated, install the necessary Python packages with:
    ```bash
    pip install -r requirements.txt
    ```

4. **Run prepare-tfvars.py**: Execute the [prepare-tfvars.py](/prepare-tfvars.py) script to automatically generate a **terraform.tfvars** file for each Terraform directory.
    ```bash
    python prepare-tfvars.py
    ```

5. **Verify tfvars Creation**: After running the script, verify that a **terraform.tfvars** file has been created in each of the Terraform directories.

### Setting up the infrastructure

To establish the infrastructure for this project, you'll need to navigate through various Terraform directories and execute Terraform commands. It's crucial to follow a specific order when setting up the infrastructure components due to some of their interdependencies:

1. **S3 Main Storage Setup**: Begin with the [main-storage-s3-tf](/main-storage-s3-tf/) directory.
    ```bash
    cd main-storage-s3-tf
    terraform init
    terraform apply # Confirm with 'yes' when prompted
    ```

2. **Batch Ingestion Setup**: 
    ```bash
    cd ../batch-ingestion-tf
    terraform init
    terraform apply # Confirm with 'yes' when prompted
    ```

     > **Note**: MSK might take upto 30 minutes to provision. Ensure its fully set up before proceeding.

    ```bash
    cd ansible
    ansible-playbook kafka-client-setup.yml
    ```

3. **Stream Ingestion Setup**: 
    ```bash
    cd ../stream-ingestion-tf
    terraform init
    terraform apply # Confirm with 'yes' when prompted
    ```

4. **Databricks Setup**:
    ```bash
    cd ../databricks-tf
    terraform init
    terraform apply # Confirm with 'yes' when prompted
    ```

    > **Note**: Note the 'databricks_host' output from the console for later use.

5. **MWAA Setup**:
    ```bash
    cd ../mwaa-orchestration-tf
    python prepare-dag.py
    terraform init
    terraform apply # Confirm with 'yes' when prompted
    ```

    > **Note**: MWAA might take upto 30 minutes to provision. Ensure its fully set up before proceeding.

6. **MWAA Databricks Connection Setup**: After MWAA is up and running, configure the Databricks connection in Airflow:

    * Navigate to **AWS Console > MWAA** and open **Airflow UI**.
    * In **Admin > Connections**, locate and edit the **databricks_default** connection.
    * Set **Host** to the 'databricks_host' URL noted earlier.
    * Set **Login** to the 'client_id' and **Password** to the 'client_secret' from your [config.yml](/config.yml).
    * In **Extra**, enter the following JSON and save the connection:
    ```json
    {
        "service_principal_oauth": true
    }
    ```

### Running Batch Processing Pipeline
To run the batch processing pipeline, follow these steps:

1. **Initiate Emulation Script**: Start by emulating data production to the API Gateway. Navigate to the [emulation-scripts](/emulation-scripts/) directory and run the [user_posting_emulation.py](/emulation-scripts/user_posting_emulation.py) script.

```bash
cd ../emulation-scripts
python user_posting_emulation.py
```

> **Note**: Allow the script to fully complete its execution. Once finished, it should have produced and sent all the records to the API Gateway, through kafka-client, MSK and MSK connect and sank the records to the S3 bucket configured in [main-storage-s3-tf](/main-storage-s3-tf/) under the 'topics' directory.

2. **Orchestrate Processing with Airflow**: Once the data is produced and stored in S3, the next step is to process it using Airflow.
    * Navigate to **AWS Console > MWAA** and open **Airflow UI**.
    * Go to the **DAGs** tab, and locate **batch_processing_dag**.
    * Trigger the DAG manually by clicking on the **play** button on the right side of the Airflow UI.

> **Note**: After the DAG completes its run, the processed data will be available in the S3 bucket set up by [main-storage-s3-tf](/main-storage-s3-tf/) under the '/delta_tables/transformed' directory. This data represents the transformed and processed output of the batch processing pipeline.

### Running Stream Processing Pipeline
To execute the stream processing pipeline, you'll need to manually initiate the Databricks notebooks and run an emulation scipt. Follow these steps:

1. **Initiate Stream Processing Notebooks in Databricks**: Unlike batch processing, stream processing isn't orchestrated with Airflow and needs to be manually triggered in the Databricks console.
    * Navigate to your **Databricks Console > Workspaces**.
    * Locate and access the workspace created by [databricks-tf](/databricks-tf/). Add your main user to this workspace and assign admin privileges. This is necessary as the workspace is initially owned by the service principal.
    * Log in to the workspace, go to **Users** and find the service principal. You'll find the notebooks uploaded by [databricks-tf](/databricks-tf/) in the service principal's user space.
    * Open the **kinesis_geo_data_stream_processing.ipynb**, **kinesis_pin_data_stream_processing.ipynb** and **kinesis_user_data_stream_processing.ipynb** notebooks. Run each notebook to start the stream processing.

> **Note**: The streaming notebooks are configured to listen to the Kinesis data streams set up by [stream-ingestion-tf](/stream-ingestion-tf/) on the pre-configured shards.

2. **Initiate Emulation Script**: Simulate data production to the API Gateway. Navigate to the [emulation-scripts](/emulation-scripts/) directory and run the [user_posting_emulation_streaming.py](/emulation-scripts/user_posting_emulation_streaming.py) emulation script for streaming.

```bash
cd ../emulation-scripts
python user_posting_emulation_streaming.py
```

> **Note**: Allow the emulation script to fully complete its execution. Once finished, manually stop the streaming notebooks in Databricks. The notebooks will have processed and stored the streaming data in near-real time in the S3 bucket configured by [main-storage-s3-tf](/main-storage-s3-tf/) under the '/test_streaming_delta_tables' directory.

#### Running Queries on Processed Data
After successfully completing the [batch processing pipeline](#running-batch-processing-pipeline), you can run queries on the processed data to extract insights or validate the transformations. Similar to the [stream processing pipeline](#running-stream-processing-pipeline), these queries are executed manually in the Databricks workspace. Follow these steps:

1. **Access the Databricks Workspace**: Log in to your Databricks workspace that you set up earlier.

2. **Locate the Notebook**: Navigate to the service principal's user space where you'll find the **queries.ipynb notebook**. This notebook contains predefined queries tailored to the processed data.

3. **Run the Notebook**:  Open the **queries.ipynb** notebook and execute the cells. As the queries run, they will fetch and display data from the processed datasets.

> **Note**: The results from these queries are displayed directly in the notebook and are not stored elsewhere.

### Architecture Tear Down
When you no longer need the infrastructure set up for this project, you can decommission it to avoid incurring unnecessary costs. To tear down the architecture, navigate to each of the terraform directories apply the following command:

```bash
terraform destroy # Confirm with 'yes' when prompted
```

> **Note**: Cloudwatch logs for MWAA must be deleted manually by navigating to AWS console and the KMS key used by MSK has deletion window of 7 days. Therefore, it will take 7 days before permanent deletetion.

#### References
* [Download python](https://www.python.org/downloads/)
* [Install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Creating a virtual environment in conda/venv](https://lynn-kwong.medium.com/how-to-create-virtual-environments-with-venv-and-conda-in-python-31814c0a8ec2)
* [Installing terraform](https://developer.hashicorp.com/terraform/install)
* [Installing/Updating aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Create a AWS account](https://aws.amazon.com/resources/create-account/)
* [Create a databricks account](https://docs.databricks.com/en/getting-started/index.html)
* [Create a new user in AWs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
* [Generating AWS access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c)
* [configure aws cli](https://cloudacademy.com/blog/how-to-use-aws-cli/)
* [Service principal for Databricks automation](https://docs.databricks.com/en/dev-tools/service-principals.html)
* [Manage your Databricks account](https://docs.databricks.com/en/administration-guide/account-settings/index.html#locate-your-account-id)
* [Addig Databricks connection to Airflow](https://airflow.apache.org/docs/apache-airflow-providers-databricks/stable/connections/databricks.html)