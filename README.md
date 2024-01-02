# Pinterest Data Pipeline &#x1F4CC;

This project, developed as part of the **AI Core Data Engineering Bootcamp**, showcases the creation of two data pipelines: a **batch-processing** data pipeline and a **stream-processing** data pipeline. Utilizing a variety of AWS services such as **API Gateway**, **Managed Services for Kafka (MSK)**, **S3**, **Databricks (Spark)**, and more, this project demonstrates comprehensive data ingestion, transformation, and storage processes. The pipelines are designed to handle sample Pinterest data on a user account on AWS, provided by the bootcamp, to produce **query-ready** data at the end of the pipeline. This endeavor serves as both a practical learning opportunity in various data engineering practices and technologies, and as a potential reference for those delving into the field.

> **Note: If you are setting up the project with Terraform on your own AWS account, please be aware that the project utilizes services that are not included in the free tier, such as MSK, MWAA, and Databricks. Consequently, you will incur some costs associated with these services.**

## Project Architecture

| ![pinterest architecture](/images/pinterest_architecture.png) |
| :------------------------------------------------: |
| pinterest architecture                              |

## Table of Contents


### Getting Started

#### Requirements
|**Name** |**Version** |
|---------|------------|
|[python](https://www.python.org/downloads/)   |3.x         |
|[ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)  |>=2.9       |
|[conda/venv](https://lynn-kwong.medium.com/how-to-create-virtual-environments-with-venv-and-conda-in-python-31814c0a8ec2) | *        |
|[terraform](https://developer.hashicorp.com/terraform/install) | >=1.0.0   |
|[aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  | 2.x        |
|[aws account](https://aws.amazon.com/resources/create-account/) | -       |
|[databricks account (not community edition)](https://docs.databricks.com/en/getting-started/index.html) | - |

#### Terraform providers
|**Name** | **Version** |
|---------|-------------|
|[aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)      | >=4.63.0    |
|[databricks](https://registry.terraform.io/providers/databricks/databricks/latest/docs) | -         |

#### Cloning the project
To clone the project, ensure you have Git installed on your system. You can download Git from the [official Git page](https://git-scm.com/downloads). Use the following command to clone the project:

```bash
git clone https://github.com/prg48/pinterest-data-pipeline.git
```

#### Setup

To initialize the project, you'll need to configure several variables within the [config.yml](/config.yml) file located at the root of the project. This file contains essential parameters for AWS, Databricks, S3 bucket names, and MWAA environment settings. Here's a brief overview of what you need to do: 

1. **AWS Configuration**: Input your AWS region, access key, and secret key. These credentials will facilitate the interaction between the Terraform scripts and your AWS account to provision necessary resources.

2. **Databricks Configuration**: Provide details such as your Databricks account ID, client ID, and client secret. These are crucial for setting up and managing your Databricks workspace through the project.

3. **S3 Bucket Names**: Assign unique names for various S3 buckets that will be used for data storage, Databricks workspace, and Airflow DAGs.

4. **MWAA Environment**: Define the name for your Managed Workflows for Apache Airflow (MWAA) environment. Ensure the naming convention follows the guidelines (e.g., using hyphens instead of underscores).

After configuring these variables, you're ready to proceed with the project setup. Ensure all the prerequisites are installed and properly configured before moving forward.

#### Getting AWS Access Keys and Configuring AWS CLI

To interact with AWS services, you'll need to [set up access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c) and [configure the AWS CLI](https://cloudacademy.com/blog/how-to-use-aws-cli/) with your credentials.

1. **Create or Use an Existing AWS User**: If you don't have a user, [create a new IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) user in your AWS account with administrative privileges. For existing users, ensure they have the necessary permissions to provision the resources required by this project.

2. **Generate Access Keys**: Once you have a user, [generate a new set of access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c) (access key ID and secret access key). These keys will be used to authenticate your requests to AWS.

3. **Update config.yml**: Enter the generated access key ID and secret access key in the respective fields (access_key and secret_key) in the [config.yml](/config.yml) file. This step is crucial as it allows Terraform and Databricks to interact with AWS services under your account.

4. **Configure AWS CLI**: [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) if you haven't already and [configure it](https://cloudacademy.com/blog/how-to-use-aws-cli/) using the **aws configure** command. Input your access key ID, secret access key, and default region when prompted. Ensure that the region matches the one specified in your [config.yml](/config.yml) file.

#### References
[Download python](https://www.python.org/downloads/)
[Install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
[Creating a virtual environment in conda/venv](https://lynn-kwong.medium.com/how-to-create-virtual-environments-with-venv-and-conda-in-python-31814c0a8ec2)
[Installing terraform](https://developer.hashicorp.com/terraform/install)
[Installing/Updating aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
[Create a AWS account](https://aws.amazon.com/resources/create-account/)
[Create a databricks account](https://docs.databricks.com/en/getting-started/index.html)
[Create a new user in AWs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
[Generating AWS access keys](https://www.youtube.com/watch?v=HuE-QhrmE1c)
[configure aws cli](https://cloudacademy.com/blog/how-to-use-aws-cli/)