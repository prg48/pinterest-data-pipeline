import requests
import random
import json
import sqlalchemy
from sqlalchemy import text
from datetime import datetime, date
import time
import base64

random.seed(100)

class AWSDBConnector:
    """
    Class that represents an AWS RDS database connector
    """
    def __init__(self):

        self.HOST = "pinterestdbreadonly.cq2e8zno855e.eu-west-1.rds.amazonaws.com"
        self.USER = 'project_user'
        self.PASSWORD = '' # Please enter password
        self.DATABASE = 'pinterest_data'
        self.PORT = 3306
        
    def create_db_connector(self):
        """
        Connects to the AWS RDS database and returns the connected engine

        Returns:
            engine: engine that is connected to the AWS RDS database
        """
        engine = sqlalchemy.create_engine(f"mysql+pymysql://{self.USER}:{self.PASSWORD}@{self.HOST}:{self.PORT}/{self.DATABASE}?charset=utf8mb4")
        return engine

new_connector = AWSDBConnector()

def json_serial(obj):
    """
    JSON serializer for objects not serialzable by default json code

    Args:
        obj (Any): The object to be serialized

    Returns:
        str: The ISO formatted string for datetime and date objects

    Raises:
        TypeError: If 'obj' is not of a type that can be serialized to JSON by this function
    """
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError (f"Type {type(obj)} not serializable.")

def create_post_payload(data: dict, partition_key: str) -> str:
    """
    This method creates a payload in the format that is compatible to post to kinesis API gateway endpoint

    Args:
        data (dict): dictionary of key-value pairs
        partition_key (str): unique partition key

    Returns:
        payload (json): json string representation of the compatible payload
    """
    json_string = json.dumps(data, default=json_serial)

    # encode the json string to bytes, then to base64
    base64_encoded = base64.b64encode(json_string.encode('utf-8')).decode('utf-8')

    return json.dumps({
        "Data": base64_encoded,
        "PartitionKey": partition_key 
    })

def post_record_to_kinesis_stream(invoke_url: str, headers: dict, data: str) -> dict:
    """
    puts a record in a kinesis data stream using API gateway kinesis integration

    Args:
        invoke_url (str): API gateway URL to post a record to kinesis stream
        headers (dict): required headers when invoking the invoke_url
        data (str): data in json string format to use as a payload when invoking invoke_url

    Returns:
        dict: dictionary of the response returned by the invoke_url
    """
    response = requests.request(
        "PUT",
        invoke_url,
        headers=headers,
        data=data
    )
    response.raise_for_status()
    return response.json()

def run_infinite_post_data_loop():
    """
    Pulls data from AWS RDS database connector and pushes it to API gateway integration for kinesis data streams.
    """
    data_index = 0

    # base kinesis api gateway URL
    base_url = "https://d7vr7kcpeh.execute-api.us-east-1.amazonaws.com/kinesis-prod"
    user = "0e3bbd435bfb"
    streams = get_kinesis_streams(base_url=base_url, user=user)
    geo_stream_invoke_url = f"{base_url}/streams/{streams['geo_stream']}/record"
    pin_stream_invoke_url = f"{base_url}/streams/{streams['pin_stream']}/record"
    user_stream_invoke_url = f"{base_url}/streams/{streams['user_stream']}/record"
    headers =  {'Content-Type': 'application/json'}

    while True:
        engine = new_connector.create_db_connector()

        with engine.connect() as connection:
            print(f"data index: {data_index}")

            # get pin data from RDS and post to appropriate stream in kinesis
            pin_string = text(f"SELECT * FROM pinterest_data LIMIT {data_index}, 1")
            pin_selected_row = connection.execute(pin_string)
            
            for row in pin_selected_row:
                pin_result = dict(row._mapping)
                payload = create_post_payload(pin_result, "test_pin")
                post_record_to_kinesis_stream(
                    invoke_url=pin_stream_invoke_url,
                    headers=headers,
                    data=payload
                )

            # get geo data from RDS and post to appropriate stream in kinesis
            geo_string = text(f"SELECT * FROM geolocation_data LIMIT {data_index}, 1")
            geo_selected_row = connection.execute(geo_string)
            
            for row in geo_selected_row:
                geo_result = dict(row._mapping)
                payload = create_post_payload(geo_result, "test_geo")
                post_record_to_kinesis_stream(
                    invoke_url=geo_stream_invoke_url,
                    headers=headers,
                    data=payload
                )

            # get user data from RDS and post to appropriate stream in kinesis
            user_string = text(f"SELECT * FROM user_data LIMIT {data_index}, 1")
            user_selected_row = connection.execute(user_string)
            
            for row in user_selected_row:
                user_result = dict(row._mapping)
                payload = create_post_payload(user_result, "test_user")
                post_record_to_kinesis_stream(
                    invoke_url=user_stream_invoke_url,
                    headers=headers,
                    data=payload
                )
            
            data_index = data_index + 1

            # print to check progress
            if (data_index % 100 == 0):
                print(f"The number of data send: {data_index}")
            
            # end of data from RDS
            if (data_index > 11153):
                break

            # sleep to not overwhelm API gateway
            time.sleep(0.5)

def get_kinesis_streams(base_url: str, user: str) -> dict:
    """
    gets the available geo, pin and user kinesis streams for a user

    Args:
        base_url (str): API gateway integration with kinesis URL
        user (str): user for whom to get kinesis stream
    
    Returns:
        dict : dictionary with geo, pin and user stream names
    """
    geo_stream = ""
    pin_stream = ""
    user_stream = ""
    response = requests.request("GET", base_url+"/streams")
    response.raise_for_status()

    for item in response.json()['StreamNames']:
        if (f"streaming-{user}" in item):
            if "geo" in item:
                geo_stream = item
            elif "pin" in item:
                pin_stream = item
            elif "user" in item:
                user_stream = item
    
    return {
        "geo_stream": geo_stream,
        "pin_stream": pin_stream,
        "user_stream": user_stream
    }

if __name__ == "__main__":
    print("Starting")
    run_infinite_post_data_loop()
    print('Working')