# Pinterest Data Pipeline &#x1F4CC;

This project, developed as part of the **AI Core Data Engineering Bootcamp**, showcases the creation of two data pipelines: a **batch-processing** data pipeline and a **stream-processing** data pipeline. Utilizing a variety of AWS services such as **API Gateway**, **Managed Services for Kafka (MSK)**, **S3**, **Databricks (Spark)**, and more, this project demonstrates comprehensive data ingestion, transformation, and storage processes. The pipelines are designed to handle sample Pinterest data on a user account on AWS, provided by the bootcamp, to produce **query-ready** data at the end of the pipeline. This endeavor serves as both a practical learning opportunity in various data engineering practices and technologies, and as a potential reference for those delving into the field.

> **Note: If you are setting up the project with Terraform on your own AWS account, please be aware that the project utilizes services that are not included in the free tier, such as MSK, MWAA, and Databricks. Consequently, you will incur some costs associated with these services.**

## Project Architecture

| ![pinterest architecture](/images/pinterest_architecture.png) |
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
Each Terraform directory in this project requires specific variables to provision the related infrastructure. These variables are typically passed with a **terraform.tfvars** file in the respective directories, eliminating the need to manually enter each variable at Terraform runtime. The script [prepare-tfvars.py](/prepare-tfvars.py) is designed to automate this process by reading the values from [config.yml](/config.yml) and preparing **terraform.tfvars** for each Terraform directory. To facilitate this automation, AWS and Databricks credentials must be supplied to [config.yml] file. The credentials can be acquired as follows:

#### Getting AWS Access Keys and Configuring AWS CLI

To interact with AWS services, you'll need to [set up access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c) and [configure the AWS CLI](https://cloudacademy.com/blog/how-to-use-aws-cli/) with your credentials.

1. **Create or Use an Existing AWS User**: If you don't have a user, [create a new IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) user in your AWS account with administrative privileges. For existing users, ensure they have the necessary permissions to provision the resources required by this project.

2. **Generate Access Keys**: Once you have a user, [generate a new set of access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c) (access key ID and secret access key). These keys will be used to authenticate your requests to AWS.

3. **Update config.yml**: Enter the generated access key ID and secret access key in the respective fields (access_key and secret_key) in the [config.yml](/config.yml) file. This step is crucial as it allows Terraform to interact with AWS services under your account.

4. **Configure AWS CLI**: [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) if you haven't already and [configure it](https://cloudacademy.com/blog/how-to-use-aws-cli/) using the **aws configure** command. Input your access key ID, secret access key, and default region when prompted. Ensure that the region matches the one specified in your [config.yml](/config.yml) file.

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

4. **Run prepare-tfvars.py**: Execute the [prepare-tfvars.py] script to automatically generate a **terraform.tfvars** file for each Terraform directory.
    ```bash
    python prepare-tfvars.py
    ```

5. **Verify tfvars Creation**: After running the script, verify that a **terraform.tfvars** file has been created in each of the Terraform directories.

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