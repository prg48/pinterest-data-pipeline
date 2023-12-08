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
* **Producer/Data Source**: serving as the data's origin, the producer in the stream-processing pipeline emulates a real-time data source. It continuously generates streaming data for **geo**, **pin**, and **user** datasets, simulating a live environment where data is consttantly being produced and collected.
* **Ingestion**: This layer is the first point of contact for the streaming data. It is responsible for efficiently ingesting the data produced by the producer. Key in this layer is the ability to handle high-velocity data streams, ensuring that the data is captured accurately, ready for the next stages of processing.
* **Databricks Spark Streaming**: At the heart of our stream-processing pipeline is the Databricks Spark Streaming layer. This layer leverages Apache Spark's capabilities to process streaming data in real time. It initiates a continuous data stream, applies necessary transformations to the incoming data, and prepares  it for storage. This step is crucial for converting raw streaming data into a format that is more suitable for analysis and querying.
* **Storage**: The transformed, query-ready data is then stored in this layer in a format that is optimized for quick data retrieval.

Below is the architecture diagram for the **stream-processing** data pipeline:

| ![stream processing architecture](/images/stream_processing_architecture.jpg) |
| :------------------------------------------------: |
| stream-processing data pipeline architecture                              |

#### Producer
In our stream-processing pipeline, the producer plays a crucial role by emulating a continuous data source. Similar to the batch-processing setup, the same data is sourced from an external RDS database provided by the bootcamp. The streaming data is handled by [user_posting_emulation_streaming.py](/stream_processing/user_posting_emulation_streaming.py) script, fetching **geo**, **pin**, and **user** data and streaming it to the **API Gateway** in the ingestion layer, one record at a time.

* **Preparing data for transmission**: The **API Gateway** requires the data to be formatted in a specific JSON payload structure, suitable for posting records to **Kinesis Data Streams**. This formatting is managed by **create_post_payload(data, partition_key)** function within our script. The function ensures that each data record is structured as per the guidelines outlined in the [Kinesis Data Streams API documentation](https://docs.aws.amazon.com/pdfs/kinesis/latest/APIReference/kinesis-api.pdf).

#### Ingestion
The ingestion layer plays a pivotal role in our stream-processing data pipeline, ensuring real-time data from the producer is reliably captured and made ready for further processing. This layer utilizes **two key AWS services**:

* **API Gateway**: Mirroring its role in the batch-processing pipeline, the API Gateway here acts as the primary entry point. Its main function is to serve as a conduit to the **Kinesis DataStreams**' REST API, where the streaming data is managed. To achieve this, we have configured the API Gateway to function as a [Kinesis proxy](https://docs.aws.amazon.com/apigateway/latest/developerguide/integrating-api-with-aws-services-kinesis.html). This setup includes various endpoints that facilitates operations such as **retrieving streams**, **deleting streams**, **posting records**, and **iterating over streams with shard iterators**.

* **Kinesis DataStreams**: Kinesis DataStreams is where the streaming data, produced by the producer, is ultimately stored for subsequent processing. It receives data from the **API Gateway** and segregates it into three distinct streams: **geo**, **pin**, and **user**. Each stream corresponds to the different data from streamed by the producer, ensuring organized and efficient data handling.

#### Databricks spark processing & Storage
In the final layer of our stream-processing data pipeline, the transformation of data is efficiently handles in Databricks, leveraging the capabilities of **Spark Structured Streaming**. We utilize three distinct notebooks to process the data streams from **Kinesis DataStreams**. Each notebook is responsible for streaming, transforming, and subsequently storing the data:

* [kinesis_geo_data_stream_processing.ipynb](/stream_processing/databricks_transformation_notebooks/kinesis_geo_data_stream_processing.ipynb) for the **geo** data stream.
* [kinesis_pin_data_stream_processing.ipynb](/stream_processing/databricks_transformation_notebooks/kinesis_pin_data_stream_processing.ipynb) for the **pin** data stream,
* [kinesis_user_data_stream_processing.ipynb](/stream_processing/databricks_transformation_notebooks/kinesis_user_data_stream_processing.ipynb) for the **user** data stream.

The transformations applied to these notebooks are similar to those performed in the [batch processing transformation](#mwaa-orchestration) notebooks, ensuring consistency across our data processing approaches. After the data is transformed, it is stored in a **S3 storage** in **delta tables parquet** format, organized into respective sub-buckets for **geo**, **pin**, and **user** data. This storage format is optimized for easy retrieval, making the data readily available for querying and other downstream analytical tasks.

### Queries
The majority of our data analysis focused on the **Transformed delta tables** bucket, which contains data processed through the [batch-processing data pipeline](#batch-processing). Detailed insights were derived by running a series of queries against this data, all of which are documented in the [queries.ipynb](/queries/queries.ipynb) notebook.

These queries were executed within the Databricks environment, utilizing both **PySpark** and **Spark SQL** to inteact with and analyze the data. This approach allows us to leverage the powerful analytical abilities of Spark, enabling efficient processing and insightful results.

Below are some examples of the queries that were performed, along with their respective results:

#### Most popular category each year
```python
# create a window function partitioned by post_year and ordered by descending order
window = Window.partitionBy("post_year").orderBy(F.desc("category_count"))

# join df_pin and df_geo and find the most popular category each year
popular_category_each_year = (
    df_pin.join(df_geo, on=df_pin.ind == df_geo.ind, how="inner")
    .withColumn("post_year", F.year(F.col("timestamp")))
    .select(F.col("post_year"), F.col("category"))
    .groupBy("post_year", "category").agg(F.count("*").alias("category_count"))
    .withColumn("rank", F.rank().over(window))
    .filter(F.col("rank") == 1)
    .drop(F.col("rank"))
)

popular_category_each_year.show()
```

results:
| post_year | category   | category_count |
|-----------|------------|----------------|
| 2017      | home-decor | 42             |
| 2018      | christmas  | 210            |
| 2019      | christmas  | 205            |
| 2020      | christmas  | 191            |
| 2021      | education  | 200            |
| 2022      | christmas  | 171            |

#### Most popular category for different age groups
```sql
%sql
CREATE OR REPLACE TEMPORARY VIEW age_group_table AS
SELECT ind, age, 
        CASE
          WHEN age BETWEEN 18 AND 24 THEN "18-24"
          WHEN age BETWEEN 25 AND 35 THEN "25-35"
          WHEN age BETWEEN 36 AND 50 THEN "36-50"
          ELSE "+50"
        END AS age_group
 FROM view_user;

CREATE OR REPLACE TEMPORARY VIEW age_group_count_table AS
SELECT category, 
        age_group, 
        COUNT(*) AS category_count,
        ROW_NUMBER() OVER (PARTITION BY age_group ORDER BY COUNT(*) DESC) as rank
FROM view_pin
INNER JOIN age_group_table ON view_pin.ind = age_group_table.ind
GROUP BY age_group, category;

SELECT age_group, category, category_count
FROM age_group_count_table
WHERE rank = 1;
```

results:
| age_group | category  | category_count |
|-----------|-----------|----------------|
| +50       | vehicles  | 114            |
| 18-24     | tattoos   | 615            |
| 25-35     | christmas | 321            |
| 36-50     | vehicles  | 215            |


#### Median follower count of users based on their joining year
```python
median_follower_count_each_year = (
    df_pin.join(df_user, "ind", "inner")
    .withColumn("post_year", F.year(F.col("date_joined")))
    .select("post_year", "follower_count")
    .dropna("any")
    .withColumn(
        "rank",
        F.row_number().over(Window.partitionBy("post_year").orderBy(F.asc("follower_count")))
    )
    .withColumn(
        "total",
        F.count("follower_count").over(Window.partitionBy("post_year"))
    )
    .filter(
        (F.col("rank") == F.col("total")/2) | (F.col("rank") == (F.col("total")+1)/2)
    )
    .select("post_year", "follower_count")
    .withColumnRenamed("follower_count", "median_follower_count")
)

median_follower_count_each_year.show()
```

results:
| post_year | median_follower_count |
|-----------|-----------------------|
| 2015      | 160000                |
| 2016      | 20000                 |
| 2017      | 4000                  |

#### Median follower count of users based on their joining year and age group
```sql
%sql
WITH age_grouped AS (
  SELECT *,
        CASE 
          WHEN age BETWEEN 18 AND 24 THEN '18-24'
          WHEN age BETWEEN 25 AND 35 THEN '25-35'
          WHEN age BETWEEN 36 AND 50 THEN '36-50'
          ELSE '+50'
        END AS age_group,
        YEAR(date_joined) AS post_year
  FROM view_user u
  INNER JOIN view_pin p
  ON u.ind = p.ind
  WHERE follower_count IS NOT NULL
),

ranked_total_data AS (
  SELECT *,
        row_number() OVER (PARTITION BY post_year, age_group ORDER BY follower_count ASC) AS rank,
        COUNT(follower_count) OVER (PARTITION BY post_year, age_group) AS total
  FROM age_grouped
)

SELECT post_year, age_group, follower_count AS median_follower_count
FROM ranked_total_data
WHERE rank = total/2 OR rank = (total+1)/2
```

results:
| post_year | age_group | median_follower_count |
|-----------|-----------|-----------------------|
| 2015      | +50       | 11000                 |
| 2015      | 18-24     | 375000                |
| 2015      | 25-35     | 37000                 |
| 2015      | 36-50     | 22000                 |
| 2016      | +50       | 3000                  |
| 2016      | 18-24     | 46000                 |
| 2016      | 25-35     | 24000                 |
| 2016      | 36-50     | 9000                  |
| 2017      | +50       | 3000                  |
| 2017      | 18-24     | 7000                  |
| 2017      | 25-35     | 4000                  |
| 2017      | 36-50     | 3000                  |

## References
* [Kafka REST proxy API documentation](https://docs.confluent.io/platform/current/kafka-rest/api.html)
* [Setup a proxy integration with a proxy resource in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)
* [Install kafka on a client machine and create a topics on MSK cluster](https://docs.aws.amazon.com/msk/latest/developerguide/create-topic.html)
* [Download confluent package containing Kafka REST proxy](https://packages.confluent.io/archive/7.2/)
* [Configure Kafka REST proxy to connect to MSK](https://swetavkamal.medium.com/how-to-call-aws-msk-managed-streaming-kafka-with-rest-api-5111c55d9bd9)
* [Download S3 sink connector](https://www.confluent.io/hub/confluentinc/kafka-connect-s3)
* [Create a custom connector in MSK](https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-connectors.html)
* [Create a custom plugin to use custom connector](https://docs.aws.amazon.com/msk/latest/developerguide/mkc-create-plugin.html)
* [Benefits of storing data in delta table format](https://medium.com/datalex/5-reasons-to-use-delta-lake-format-on-databricks-d9e76cf3e77d)
* [DatabricksSubmitRunOperator](https://airflow.apache.org/docs/apache-airflow-providers-databricks/stable/operators/submit_run.html)
* [Kinesis Data Streams API documentation](https://docs.aws.amazon.com/pdfs/kinesis/latest/APIReference/kinesis-api.pdf)
* [Apache Spark's Structured Streaming with Amazon Kinesis on Databricks](https://www.databricks.com/blog/2017/08/09/apache-sparks-structured-streaming-with-amazon-kinesis-on-databricks.html)