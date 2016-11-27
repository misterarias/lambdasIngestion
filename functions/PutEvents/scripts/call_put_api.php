#!/usr/bin/env php
<?php
$url = 'https://omr7ynb51a.execute-api.eu-west-1.amazonaws.com/prod/PutEvents';
$apiKey = 'pjrC2wi8phaA5Z1PiRK3oaq5x4SGqFcx4QxUKZwk' ;
$eventFile = dirname(__FILE__). '/../events/raw-put-event-1.js';

// Load data from file as an associative array
$string = file_get_contents("$eventFile");
$json_as_an_array = json_decode($string, true);

// Convert an associative array into a json-in-a-string
$json_string = json_encode($json_as_an_array);

$curl = curl_init();
curl_setopt($curl, CURLOPT_HTTPHEADER, array(
  "x-api-key: $apiKey",
  "Content-Type: application/json",
  "Content-Length: " . strlen($json_string)
));
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
curl_setopt($curl, CURLOPT_POSTFIELDS, $json_string);
$result = curl_exec($curl);

curl_close($curl);
?>
