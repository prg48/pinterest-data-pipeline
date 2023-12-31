{
  "openapi" : "3.0.1",
  "info" : {
    "title" : "KinesisProxy",
    "version" : "2023-11-07T18:38:13Z"
  },
  "paths" : {
    "/streams/{stream-name}/sharditerator" : {
      "get" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        }, {
          "name" : "shard-id",
          "in" : "query",
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/GetShardIterator",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.querystring.shard-id" : "method.request.querystring.shard-id",
            "integration.request.header.Content-Type" : "'x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"ShardId\": \"$input.params('shard-id')\",\n    \"ShardIteratorType\": \"TRIM_HORIZON\",\n    \"StreamName\": \"$input.params('stream-name')\"\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      }
    },
    "/streams/{stream-name}/records" : {
      "get" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        }, {
          "name" : "Shard-Iterator",
          "in" : "header",
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/GetRecords",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"ShardIterator\": \"$input.params('Shard-Iterator')\"\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      },
      "put" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/PutRecords",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Content-Type" : "'x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"StreamName\": \"$input.params('stream-name')\",\n    \"Records\": [\n       #foreach($elem in $input.path('$.records'))\n          {\n            \"Data\": \"$util.base64Encode($elem.data)\",\n            \"PartitionKey\": \"$elem.partition-key\"\n          }#if($foreach.hasNext),#end\n        #end\n    ]\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      }
    },
    "/streams/{stream-name}" : {
      "get" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/DescribeStream",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Content-Type" : "'x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"StreamName\": \"$input.params('stream-name')\"\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      },
      "post" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/CreateStream",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Content-Type" : "'x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"ShardCount\": #if($input.path('$.ShardCount') == '') 5 #else $input.path('$.ShardCount') #end,\n    \"StreamName\": \"$input.params('stream-name')\"\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      },
      "delete" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/DeleteStream",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Content-Type" : "'x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"StreamName\": \"$input.params('stream-name')\"\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      }
    },
    "/streams/{stream-name}/record" : {
      "put" : {
        "parameters" : [ {
          "name" : "stream-name",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/PutRecord",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Content-Type" : "'x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{\n    \"StreamName\": \"$input.params('stream-name')\",\n    \"Data\": \"$util.base64Encode($input.json('$.Data'))\",\n    \"PartitionKey\": \"$input.path('$.PartitionKey')\"\n}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      }
    },
    "/streams" : {
      "get" : {
        "responses" : {
          "200" : {
            "description" : "200 response",
            "content" : {
              "application/json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "credentials" : "${execution_role_arn}",
          "httpMethod" : "POST",
          "uri" : "arn:aws:apigateway:${region}:kinesis:action/ListStreams",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.header.Content-Type" : "'application/x-amz-json-1.1'"
          },
          "requestTemplates" : {
            "application/json" : "{}"
          },
          "passthroughBehavior" : "when_no_templates",
          "type" : "aws"
        }
      }
    }
  },
  "components" : {
    "schemas" : {
      "Empty" : {
        "title" : "Empty Schema",
        "type" : "object"
      }
    }
  }
}