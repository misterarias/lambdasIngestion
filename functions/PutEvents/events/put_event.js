// (40.4169514,-3.7057172) es el Km. 0 de la puerta del sol
var center_longitude = -3.7057172, center_latitude = 40.4169514;
var device_ids = [5392630, 561283, 89123];

function coinToss() {
  return Math.random() < 0.8;
}

module.exports =
{
  context: {
    stage: "local",
  }, body: {
    "source": "android",
    "Method": "UpdateAreas",
    "deviceId":  device_ids[Math.floor(Math.random() * device_ids.length)],
    "appToken": "yvghukl123",
    "oldlatitude": center_latitude,
    "oldlongitude": center_longitude,
    "latitude": coinToss() ? (center_latitude + 0.5*Math.random()) : 0 ,
    "longitude": coinToss() ? (center_longitude + 0.5*Math.random()) : 0,
    "postcode": null,
    "country": "España",
    "eventType": "webtrack"
  }
}
;
