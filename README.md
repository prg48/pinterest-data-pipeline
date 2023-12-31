# Pinterest Data Pipeline &#x1F4CC;

This project, developed as part of the **AI Core Data Engineering Bootcamp**, showcases the creation of two data pipelines: a **batch-processing** data pipeline and a **stream-processing** data pipeline. Utilizing a variety of AWS services such as **API Gateway**, **Managed Services for Kafka (MSK)**, **S3**, **Databricks (Spark)**, and more, this project demonstrates comprehensive data ingestion, transformation, and storage processes. The pipelines are designed to handle sample Pinterest data on a user account on AWS, provided by the bootcamp, to produce **query-ready** data at the end of the pipeline. This endeavor serves as both a practical learning opportunity in various data engineering practices and technologies, and as a potential reference for those delving into the field.

> **Note: If you are setting up the project with Terraform on your own AWS account, please be aware that the project utilizes services that are not included in the free tier, such as MSK, MWAA, and Databricks. Consequently, you will incur some costs associated with these services.**

## Project Architecture

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
git clone
```

#### Setup

* 