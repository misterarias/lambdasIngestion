# Ingestion using Lambda

Small development environment to code, test and upload [AWS Lambda functions](http://docs.aws.amazon.com/lambda/latest/dg/welcome.html).

## Contents

### *functions*

The Lambda functions themselves, as defined in the AWS Console

* PutEvents - inserts events into a given DynamoDB table
* RequestEvents - retrieves events that match a certain timestamp (secondary index), with an optional 'deviceType' field for further filtering.
* Register - Uses a Lambda endpoint to retrieve current configuration from an EC2-backed Redis instance, given the device is active on the backend

### *devops*

Docker containers for local testing:

* *dynamodb* - Used to store and query data inserted by PutEvents
* *redis* - Redis server that stores fake client configurations for the Register endpoint
* *mock_server* - Flask server used to Mock real API calls to our backend, used by the Register Endpoint

## How to test

There are *npm* scripts for all the commands, and some generic commands to use:

* *npm start/stop* - Starts or stops the containers needed for local testing
* *npm test* - Creates a new DynamoDB Table, inserts 50 events, and checks if 50 can be retrieved.
* *npm run-scripts register* - Runs a local 'Register' call, to test *redis* and *requests* libraries integration.
