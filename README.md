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
* **Producer/Data Source**: This is the origin of the data. It emulates as a data source that generates the data we need to process. This is the source that produces the above mentioned **pin**, **geo** and **user** data.
* **Ingestion**: This layer is responsible for ingesting data produced by the source. It ensures that data is reliably captured and made available for processing.
* **MWAA orchestration**: This layer orchestrates the processing of data, managing the workflow and ensuring that data processing tasks are executed in the correct order and manner.
* **Storage**: This layer stores the data in various stages of the pipeline, accomodating both raw and processed data.

Below is the architecture diagram for the **batch-processing** data pipeline:

| ![batch processing architecture](/images/batch_processing_architecture.jpg) |
| :------------------------------------------------: |
| batch-processing data pipeline architecture                              |

#### Producer

The producer emulates a data source that generates data. The data is sourced from an external RDS database provided by the bootcamp. The [user_posting_emulation.py](batch_processing/user_posting_emulation.py) script is responsible with loading **pin**, **geo**, and **user** data from the database. It then prepares this data for transmission to the **ingestion layer** entrypoint, the **API Gateway**.

* **Preparing data for transmission**:
To send data to the API Gateway, it must be formatted as a specific JSON payload structure expected by the **Kafka client (Kafka REST proxy)** endpoint. The **create_post_payload(data)** function in the script formats the data as expected by the [Kafka REST proxy API documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html) to post **data (records)** to **kafka cluster (MSK)** topics. 

#### Ingestion

The ingestion layer is responsible for making sure that the data is reliably captured and ready for processing. This layer integrates **three different AWS services**:

* **API Gateway**: 
The API Gateway serves as the entrypoint for the ingestion layer. Its primary function is to enable the **producer** (described in the previous section) to send a POST request with a **data (record) payload**. This request is made through an API call, intended to forward the data to our **Kafka cluster (MSK)** service.
To facilitate this, we set up a [proxy resource](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html) within the API Gateway. This proxy resource is designed to route all API calls from the **producer** directly to the **Kafka client (Kafka REST proxy)**. The Kafka client then handles these requests, ensuring that the records are appropriately posted to topics within the **Kafka cluster (MSK)**. 

* **Kafka client (Kafka REST proxy)**:
The Kafka client, hosted on an **EC2 instance**, serves two primary functions in our ingestion layer:

    1. **Topic Creation in kafka Cluster (MSK)**:
    The first responsibility of the Kafka client is to establish the necessary topic on the **Kafka cluster (MSK)**. These topics correspond to the **pin**, **geo**, and **user** data sets. To achieve this, [Kafka was installed on the EC2 instance and relevant topics created](https://docs.aws.amazon.com/msk/latest/developerguide/create-topic.html) within the **Kafka cluster (MSK)**, setting the foundation for data categorization and management.

    2. **Handling API Gateway requests**:
    The second key role of the Kafka client is to process requests received from the **API Gateway**. For this purpose, The [Confluent package, which includes the Kafka REST functionality, was downloaded](https://packages.confluent.io/archive/7.2/) on the EC2 instance. This setup was [configured to connect to our Kafka cluster (MSK)](https://swetavkamal.medium.com/how-to-call-aws-msk-managed-streaming-kafka-with-rest-api-5111c55d9bd9), enabling the Kafka client to handle incoming requests effectively. This configuration ensures that the Kafka client can receive and process data payloads forwarded by the **API Gateway**, facilitating seamless data flow into the Kafka topics.

* **Kafka cluster (MSK)**:
    The Managed Streaming for Kafka (MSK) service, or simply the Kafka cluster, represents the final component of our ingestion layer. It serves as the repository for the topics corresponding to the **geo**, **pin**, and **user** data sets. The topics, created by the Kafka client, are where the data forwarded by the **API Gateway** through the **Kafka client (Kafka REST proxy)** is stored.

    A critical aspect of our data flow involves transferring this data to S3 for durable storage. To facilitate this, we implemented an **S3 sink connector**. This process involves several steps:

    1. **S3 Sink connector Setup**:
    We started by [downloading the S3 sink connector](https://www.confluent.io/hub/confluentinc/kafka-connect-s3) and storing it in our S3 bucket. This connector is essential for enabling the movement of data from Kafka topics to S3.
    2. **Custom Connector and Plugin Creation**: Next, we created a [custom connector](https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-connectors.html) and a [custom plugin](https://docs.aws.amazon.com/msk/latest/developerguide/mkc-create-plugin.html) using the S3 sink connector. This setup allows for seamless data transfer from our Kafka topics directly to designated S3 buckets, ensuring efficient and reliable data storage.

    Through these mechanisms, the Kafka cluster (MSK) not only stores incoming data but also plays a pivotal role in the onward movement of data to S3, forming a crucial link in the data processing pipeline.

#### Storage
The storage layer in our pipeline plays a pivotal role in maintaining data accessibility and integrity. It is structured to store different types of data, each serving a specific purpose in the data lifecycle. It primarily handles three categories of data: 

* **Topics bucket**:
This bucket is a direct receipient of data from the **Kafka cluster (MSK)** via the **S3 sink connector**. It is organized into three sub-buckets: **geo**, **pin**, and **user**, corresponding to the different data we handle. The data in this bucket is in its raw form, stored as **JSON** files. This setup ensures that the initial, unprocessed data is preserved in its original state for any necessary reference or processing.

* **Raw delta tables bucket**:
The raw data from the Topic bucket undergoes an initial transformation and is stored in this bucket in the **delta table parquet** file format. This transformation is facilitated by [load_data_from_S3_and_save_as_delta_tables.ipynb](/batch_processing/databricks_transformation_notebooks/load_data_from_S3_and_save_as_delta_tables.ipynb) notebook in **Databricks**. Similar to the Topics bucket, it contains three sub-buckets for **geo**, **pin**, and **user** data. Storing data as delta tables in this manner enhances the efficiency and speed of data retrieval, making it a crucial step in our data management process.

* **Transformed delta tables bucket**:
This bucket is the final storage point for proecssed data. It contains data that has been further refined and transformed from the **Raw delta tables** bucket. The transformation processes are carried out by specific notebooks: [clean_df_geo.ipynb](/batch_processing/databricks_transformation_notebooks/clean_df_geo.ipynb) for geo data, [clean_df_pin.ipynb](/batch_processing/databricks_transformation_notebooks/clean_df_pin.ipynb) for pin data, and [clean_df_user.ipynb](/batch_processing/databricks_transformation_notebooks/clean_df_user.ipynb) for user data. Post-transformation, the data is stored back in **delta table parquet** format, segregated into **geo**, **pin**, and **user** sub-buckets. This bucket is optimized for end-user queries, offering processed and query-ready data for various analytical purposes.

#### MWAA orchestration
The Managed Workflow for Apache Airflow (MWAA) represents the final layer in our data pipeline, tasked with orchestrating both the initial and final transformations of data. It handles the transformation of data from the **Topics bucket** and subsequently from the **Raw delta tables bucket**.

The orchestration process is implemented in **Airflow**, with the detailed implementation available in [batch_processing_dag.py](/batch_processing/dags/batch_processing_dag.py) script. The DAG graph illustrating this orchestration is shown below:

| ![Airflow dag graph for batch processing](/images/batch_processing_dag.png) |
| :------------------------------------------------: |
| Airflow dag graph for batch processing orchestration                            |

Within this orchestration framework, four key notebooks hosted in **Databricks** leverage the **Spark** processing framework:

* **clean_data_from_S3_and_save_as_delta_tables** : 
Initiated by the **clean_data_from_S3_and_save_as_delta_tables** task in MWAA, this notebook loads data from the **Topics bucket**, transforms it into **delta format**, and stores the transformed data in the **Raw delta tables bucket**. The implementation is found in [load_data_from_S3_and_save_as_delta_tables.ipynb](/batch_processing/databricks_transformation_notebooks/load_data_from_S3_and_save_as_delta_tables.ipynb).

* **clean_df_geo**:
    Triggered by the **clean_geo_data_and_save_as_delta_table** task in MWAA, this notebook processes **geo** data from the **Raw delta tables bucket**. The transformations include:
        * Combining latitude and longitude into a single struct column.
        * Converting the timestamp column to the timestamp data type.
        * Reordering columns

    The transformed data is then saved in the **Transformed delta tables bucket** under the **geo** sub-bucket. See [clean_df_geo.ipynb](/batch_processing/databricks_transformation_notebooks/clean_df_geo.ipynb) for details.

* **clean_df_pin**:
    The **clean_pin_data_and_save_as_delta_table** task in MWAA initiates this notebook to transform **pin** data. Key transformations include:
        * Replacing empty strings and irrelevant values with null.
        * Converting the follower_count column from numerical abbreviation to numeric string form, then to an integer.
        * Renaming the index column to ind.

    Post-transformation, data is stored in the **Transformed delta tables bucket** under the **pin** sub-bucket. Implementation details are in [clean_df_pin.ipynb](/batch_processing/databricks_transformation_notebooks/clean_df_pin.ipynb).

* **clean_df_user**:
    Initiated by the **clean_user_data_and_save_as_delta_table** task, this notebook processes **user** data with transformations such as:
        * Merging first_name and last_name into a new column, user_name.
        * Dropping the original first_name and last_name columns.
        * Converting the date_joined column to timestamp format.

    The final output is saved in the **Transformed delta tables bucket** in the **user** sub-bucket. Refer to [clean_df_user.ipynb](/batch_processing/databricks_transformation_notebooks/clean_df_user.ipynb) for the notebook.

These notebooks are orchestrated in MWAA using the [DatabricksSubmitRunOperator](https://airflow.apache.org/docs/apache-airflow-providers-databricks/stable/operators/submit_run.html). As depicted in the DAG graph, the **load_data_from_S3_and_save_it_as_delta_tables** task is executed first, followed by the parallel execution of the other transformation tasks.

### Stream-processing
The stream-processing pipeline in the project, while similar to the batch-processing pipeline, is specifically designed to handle real-time data flows. It utilizes the same datasets -**geo**, **pin**, and **user**- and is composed of several distinct layers, each playing a crucial role in the streaming lifecycle:
* **producer**: serving as the data's origin, the producer in the stream-processing pipeline emulates a real-time data source. It continuously generates streaming data for **geo**, **pin**, and **user** datasets, simulating a live environment where data is consttantly being produced and collected.
* **Ingestion**: This layer is the first point of contact for the streaming data. It is responsible for efficiently ingesting the data produced by the producer. Key in this layer is the ability to handle high-velocity data streams, ensuring that the data is captured accurately, ready for the next stages of processing.
* **Databricks Spark Streaming**: At the heart of our stream-processing pipeline is the Databricks Spark Streaming layer. This layer leverages Apache Spark's capabilities to process streaming data in real time. It initiates a continuous data stream, applies necessary transformations to the incoming data, and prepares  it for storage. This step is crucial for converting raw streaming data into a format that is more suitable for analysis and querying.
* **Storage**: The transformed, query-ready data is then stored in this layer in a format that is optimized for quick data retrieval.

Below is the architecture diagram for the **stream-processing** data pipeline:

| ![stream processing architecture](/images/stream_processing_architecture.jpg) |
| :------------------------------------------------: |
| stream-processing data pipeline architecture                              |

## References
* [Kafka REST proxy API documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html)
* [Setup a proxy integration with a proxy resource in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)
* [Install kafka on a client machine and create a topics on MSK cluster](https://docs.aws.amazon.com/msk/latest/developerguide/create-topic.html)
* [Download confluent package containing Kafka REST proxy](https://packages.confluent.io/archive/7.2/)
* [Configure Kafka REST proxy to connect to MSK](https://swetavkamal.medium.com/how-to-call-aws-msk-managed-streaming-kafka-with-rest-api-5111c55d9bd9)
* [Download S3 sink connector](https://www.confluent.io/hub/confluentinc/kafka-connect-s3)
* [Create a custom S3 sink connector](https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-connectors.html)
* [Create a custom plugin to use custom connector](https://docs.aws.amazon.com/msk/latest/developerguide/mkc-create-plugin.html)
* [Benefits of storing data in delta table format](https://medium.com/datalex/5-reasons-to-use-delta-lake-format-on-databricks-d9e76cf3e77d)
* [DatabricksSubmitRunOperator](https://airflow.apache.org/docs/apache-airflow-providers-databricks/stable/operators/submit_run.html)