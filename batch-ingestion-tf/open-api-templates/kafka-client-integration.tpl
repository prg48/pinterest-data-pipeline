{
  "openapi" : "3.0.1",
  "info" : {
    "title" : "0e3bbd435bfb",
    "version" : "2023-11-06T19:32:16Z"
  },
  "paths" : {
    "/{proxy+}" : {
      "options" : {
        "parameters" : [ {
          "name" : "proxy",
          "in" : "path",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "200 response",
            "headers" : {
              "Access-Control-Allow-Origin" : {
                "schema" : {
                  "type" : "string"
                }
              },
              "Access-Control-Allow-Methods" : {
                "schema" : {
                  "type" : "string"
                }
              },
              "Access-Control-Allow-Headers" : {
                "schema" : {
                  "type" : "string"
                }
              }
            },
            "content" : {
              "application/vnd.kafka.v2+json" : {
                "schema" : {
                  "$ref" : "#/components/schemas/Empty"
                }
              }
            }
          }
        },
        "x-amazon-apigateway-integration" : {
          "responses" : {
            "default" : {
              "statusCode" : "200",
              "responseParameters" : {
                "method.response.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
                "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
                "method.response.header.Access-Control-Allow-Origin" : "'*'"
              }
            }
          },
          "requestTemplates" : {
            "application/json" : "{\"statusCode\": 200}"
          },
          "passthroughBehavior" : "when_no_match",
          "type" : "mock"
        }
      },
      "x-amazon-apigateway-any-method" : {
        "parameters" : [ {
          "name" : "proxy",
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
          "httpMethod" : "ANY",
          "uri" : "http://${public_ip}:8082/{proxy}",
          "responses" : {
            "default" : {
              "statusCode" : "200"
            }
          },
          "requestParameters" : {
            "integration.request.path.proxy" : "method.request.path.proxy"
          },
          "passthroughBehavior" : "when_no_match",
          "cacheNamespace" : "95yu56",
          "cacheKeyParameters" : [ "method.request.path.proxy" ],
          "type" : "http_proxy"
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