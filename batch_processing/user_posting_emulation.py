import requests
from datetime import date, datetime
from time import sleep
import random
import json
import sqlalchemy
from sqlalchemy import text

random.seed(100)

class AWSDBConnector:
    """
    Class that represents an AWS RDS database connector
    """
    def __init__(self):

        self.HOST = "pinterestdbreadonly.cq2e8zno855e.eu-west-1.rds.amazonaws.com"
        self.USER = 'project_user'
        self.PASSWORD = ':t%;yCY3Yjg'
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

def create_post_payload(data: dict) -> str:
    """
    This method creates a payload in the format that is compatible to post to kafka REST proxy endpoint

    Args:
        data (dict): dictionary of key-value pairs

    Returns:
        payload (json): json string representation of the compatible payload
    """
    return json.dumps({
        "records":[
            {
                "value": data
            }
        ]
    }, default=json_serial)


def run_infinite_post_data_loop():
    """
    Pulls data from AWS RDS database connector and pushes it to the kafka REST API endpoints.
    """
    data_index = 0
    while True:
        engine = new_connector.create_db_connector()
        base_url = "https://d7vr7kcpeh.execute-api.us-east-1.amazonaws.com/prod"
        pin_url = base_url + "/topics/0e3bbd435bfb.pin"
        geo_url = base_url + "/topics/0e3bbd435bfb.geo"
        user_url = base_url + "/topics/0e3bbd435bfb.user"
        headers =  {'Content-Type': 'application/vnd.kafka.json.v2+json'}

        with engine.connect() as connection:

            # get pin data from RDS and post to appropriate topic in kafka REST proxy
            pin_string = text(f"SELECT * FROM pinterest_data LIMIT {data_index}, 1")
            pin_selected_row = connection.execute(pin_string)
            
            for row in pin_selected_row:
                pin_result = dict(row._mapping)
                payload = create_post_payload(pin_result)
                pin_response = requests.request("POST", pin_url, headers=headers, data=payload)
                pin_response.raise_for_status()

            # get geo data from RDS and post to appropriate topic in kafka REST proxy
            geo_string = text(f"SELECT * FROM geolocation_data LIMIT {data_index}, 1")
            geo_selected_row = connection.execute(geo_string)
            
            for row in geo_selected_row:
                geo_result = dict(row._mapping)
                payload = create_post_payload(geo_result)
                geo_response = requests.request("POST", geo_url, headers=headers, data=payload)
                geo_response.raise_for_status()

            # get user data from RDS and post to appropriate topic in kafka REST proxy
            user_string = text(f"SELECT * FROM user_data LIMIT {data_index}, 1")
            user_selected_row = connection.execute(user_string)
            
            for row in user_selected_row:
                user_result = dict(row._mapping)
                payload = create_post_payload(user_result)
                user_response = requests.request("POST", user_url, headers=headers, data=payload)
                user_response.raise_for_status()
            
            data_index = data_index + 1

            # print to check progress
            if (data_index % 100 == 0):
                print(f"The number of data send: {data_index}")
            
            # end of data from RDS
            if (data_index > 11153):
                break

            # sleep to not overwhelm API gateway
            sleep(0.5)

if __name__ == "__main__":
    print("Starting")
    run_infinite_post_data_loop()
    print('Working')
