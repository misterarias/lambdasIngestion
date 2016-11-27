var AWS = require('aws-sdk');

exports.handler = function(event, context) {

  function getDb(ev) {
    var dynamodb = '';
    if (ev.hasOwnProperty("local") && ev.local === true) {
      console.log("Using Local DynamoDB instance!");
      dynamodb = new AWS.DynamoDB({
        'endpoint': new AWS.Endpoint('http://localhost:8000/')
      });
    } else {
      dynamodb = new AWS.DynamoDB();
    }
    return dynamodb;
  }

  var dynamodb = getDb(event);
  var table_name = "Events";
  dynamodb.deleteTable({
    TableName: table_name
  }, function(err, data) {
    if (!err) console.log("Deleted table: " + table_name);

    var params = {
      TableName: table_name,
      KeySchema: [
        { AttributeName: "eventType", KeyType: "HASH"},  //Partition key
        { AttributeName: "recvTimestamp", KeyType: "RANGE" }  //Sort key
      ],
      AttributeDefinitions: [
        { AttributeName: "eventType", AttributeType: "S" },
        { AttributeName: "recvTimestamp", AttributeType: "N" },
      ],
      ProvisionedThroughput:  {
        ReadCapacityUnits: 10,
        WriteCapacityUnits: 10
      }
    };

    dynamodb.createTable(params, function(err, data) {
      if (err) {
        console.log(err);
        return ;
      }
      console.log('Successfully created table ' + table_name);
      context.succeed("Ok!");
    });
  });
};

