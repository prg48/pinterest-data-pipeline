# Pinterest Data Pipeline &#x1F4CC;

This project, developed as part of the **AI Core** Data Engineering Bootcamp, showcases the creation of two distinct data pipelines: a **batch-processing** data pipeline and a **stream-processing** data pipeline. The project utilizes a range of different AWS services like **API Gateway**, **Managed services for kafka (MSK)**, **S3**, **Databricks (Spark)** etc to demonstrate data ingestion, transformation and storage for the pipelines. The pipelines handled sample pinterest data on a user account on AWS, both provided by the bootcamp to produce **query-ready** data at the end of the pipeline. This project serves as both a practical learning opportunity in various data engineering practices and technologies, and as a possible reference for those exploring the field.

## Table of Contents

### Data

A sample pinterest data was provided by the bootcamp. The data consists of three main datasets: **pin**, **geo** and **user**. Hosted on RDS, the data was accessed using credentials supplied by the bootcamp. The same dataset was used for both the **batch** and **stream** data pipelines. Below are the dataframe schemas for the raw and processed dataframes.

| ![raw dataframe schema](/images/raw_df_schema.jpg) |
| :------------------------------------------------: |
| raw dataframe schema                               |

| ![processed dataframe schema](/images/processed_df_schema.jpg) |
| :------------------------------------------------: |
| processed dataframe schema                               |

### Batch-processing

The batch processing architecture in the project consists of a number of different layers, each playing a crucial role in the data processing lifecycle: 
* **producer or data source**: This is the origin of the data. It emulates as a data source that generates the data we need to process. This is the source that produces the above mentioned **pin**, **geo** and **user** data.
* **ingestion**: This layer is responsible for ingesting data produced by the source. It ensures that data is reliably captured and made available for processing.
* **MWAA orchestration**: This layer orchestrates the processing of data, managing the workflow and ensuring that data processing tasks are executed in the correct order and manner.
* **storage**: This layer stores the data in various stages of the pipeline, accomodating both raw and processed data.

Below is the architecture diagram for the **batch processing** system:

| ![batch processing architecture](/images/batch_processing_architecture.jpg) |
| :------------------------------------------------: |
| batch processing architecture                               |

#### Producer

The producer emulates a data source generates data. The data is sourced from an external RDS database provided by the bootcamp. The [user_posting_emulation.py](batch_processing/user_posting_emulation.py) script is responsible with loading **pin**, **geo**, and **user** data from the database. It then prepares this data for transmission to the **ingestion layer** entrypoint, the **API Gateway**.

* **Preparing data for transmission**:
To send data to the API Gateway, it must be formatted as a specific JSON payload structure expected by the **Kafka client (Kafka REST proxy)** endpoint. The **create_post_payload(data)** function in the script formats the data as expected by the [Kafka REST proxy API documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html) to post **data (records)** to **kafka cluster (MSK)** topics. 

#### Ingestion

The ingestion layer is responsible for making sure that the data is reliably captured and ready for processing. This layer integrates **three different AWS services**:

* **API Gateway**: 
The API Gateway serves as the entrypoint for the ingestion layer. Its primary function is to enable the **producer** (described in the previous section) to send a POST request with a **data (record) payload**. This request is made through an API call, intended to forward the data to our **Kafka cluster (MSK)** service.
To facilitate this, we set up a [proxy resource](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html) within the API Gateway. This proxy resource is designed to route all API calls from the **producer** directly to the **Kafka client (Kafka REST proxy)**. The Kafka client then handles these requests, ensuring that the records are appropriately posted to topics within the **Kafka cluster (MSK)**. 

## References
* [Kafka REST proxy API documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html)
* [Setup a proxy integration with a proxy resource in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)