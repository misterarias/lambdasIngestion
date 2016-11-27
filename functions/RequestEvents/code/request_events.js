var AWS = require('aws-sdk');

exports.handler = function(event, context) {

  function getTableNameFrom(ev) {
    if ( ev.context.stage === "prod") {
      return 'ClousrEvents';
    } else {
      return 'Events';
    }
  }

  function getDb(ev) {
    if (ev.context.stage === "local") {
      console.log("Using Local DynamoDB instance!");
      AWS.config.update({
        'endpoint': new AWS.Endpoint('http://localhost:8000/')
      });
    }
    return new AWS.DynamoDB.DocumentClient();
  }

  var dynamo = getDb(event);
  var table_name = getTableNameFrom(event);
  var timestamp = event.body.recvTimestamp || 0;
  var event_type = event.body.hasOwnProperty("eventType") ? event.body.eventType : '1' ;
  var params = {
    TableName: table_name,
    KeyConditionExpression: 'recvTimestamp > :ts  AND eventType = :event_type',
    ExpressionAttributeValues: {
      ':ts': timestamp,
      ':event_type': event_type
    }
  };

  function get_items(p)  {
    dynamo.query(p, function(err, data) {
      if (err) {
        console.log(err);
        context.fail(err);
      }

      items = items.concat(data.Items) ;
      if (data.LastEvaluatedKey !== undefined) {
        p.ExpressionAttributeValues[':ts'] = data.LastEvaluatedKey.recvTimestamp;
        get_items(p);
      } else {
        context.succeed({'Items':items, 'Count': items.length});
      }
    });
  }
  var items = [];
  get_items(params);
};
