'use strict' ;

exports.handler = function(event, context) {

  function getTableNameFrom(ev) {
    if ( ev.context.stage === "prod") {
      return 'ClousrEvents';
    } else {
      return 'Events';
    }
  }

  function getDb(ev) {
    var AWS = require('aws-sdk');
    if (ev.context.stage === "local") {
      console.log("Using Local DynamoDB instance!");
      AWS.config.update({
        'endpoint': new AWS.Endpoint('http://localhost:8000/')
      });
    }
    return new AWS.DynamoDB.DocumentClient();
  }

  function encodeItemFromObject(object_name, key) {

    var param_value = object_name[key];
    if (param_value === undefined || param_value === "") {
      return undefined;
    }

    return param_value;
  }

  function get_keys_from(data) {
      if (data === undefined || data === "" || data === null) {
          return [];
      }

      if (data.hasOwnProperty("keys")) {
          return data.keys;
      }
      return Object.keys(data);
  }

  // Read the received object's keys, if any
  var body = event.body;
  var keys = get_keys_from(body) ;
  if (keys.length === 0) {
      context.done('ERROR: Empty event body received');
      return;
  }

  // For each key, extract its type and render it for the target DB
  var eventData = {};
  keys.forEach(function(key) {
    var field_for_db = encodeItemFromObject(body, key);
    if (field_for_db !== undefined)  {
      eventData[key] = field_for_db;
    } else {
      console.log("Undefined value for key", key, body[key]);
    }
  });


  // Make sure the received timestamp is present,it's the sort key
  eventData.recvTimestamp = new Date().getTime();

  // Make sure mandatory Params are in
  var mandatoryParams = ['appToken', 'eventType', 'deviceId', 'source'];
  var eventDataKeys = get_keys_from(eventData);
  var errorMsg = null;
  for (var key in mandatoryParams) {
      var keyName = mandatoryParams[key];
      errorMsg = null;
      if (eventDataKeys.indexOf(keyName) < 0)  {
        errorMsg = "Missing mandatory parameter '" + keyName + "'";
      } else if (eventData[keyName] === "" || eventData[keyName].length === 0) {
        errorMsg = "Missing value for mandatory parameter '" + keyName + "'";
      }

      if (errorMsg !== null) {
        console.log(errorMsg);
        context.fail(errorMsg);
        return;
      }
  }

  // Make sure we ingest only supported events
  var eventType = eventData.eventType;
  if (['apps', 'locations', 'webtrack', 'indigitall'].indexOf(eventType) < 0) {
    errorMsg = "Unsupported event Type: '" + eventType + "'";
    console.log(errorMsg);
    context.fail(errorMsg);
    return;
  }

  // Get data into the database
  var dynamodb = getDb(event);
  var tableName = getTableNameFrom(event);

  dynamodb.put({
    "TableName" : tableName,
    "Item" : eventData
  }, function(err, data) {
    if (err) {
        console.log('Error while inserting data',
          JSON.stringify(eventData, null, 1), err );
        context.done('ERROR: Dynamo failed: ' + err);
    } else {
        var msg = 'Inserted data for event ' + eventData.eventType + ' to table ' + tableName ;
        console.log(msg);
        context.done(null, msg);
    }
  });
};
