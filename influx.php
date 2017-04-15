#!/usr/bin/php
<?php

error_reporting(E_ERROR | E_WARNING | E_PARSE);

$configfile = dirname(__FILE__) . DIRECTORY_SEPARATOR . "influx.ini";

if (!file_exists($configfile)) {
  die("Missing influx.ini" . PHP_EOL);
}

$config = parse_ini_file($configfile);

$date = $argv[1];

$json = file_get_contents("php://stdin");
$data = json_decode($json);

foreach ($data->usage as $d) {
  
  $hour = $d->title;
  $kwh = $d->usage0;

  $influx = sprintf("kWh value=%f %d", $kwh, strtotime($date . $hour . ":00:00") . "000000000");

  echo $influx . "\n";

  $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL, $config['url']);
  curl_setopt($ch, CURLOPT_BINARYTRANSFER, TRUE);
  if ($config['user'] && $config['pass']) {
    curl_setopt($ch, CURLOPT_USERPWD, $config['user'] . ":" . $config['pass']);
  }
  curl_setopt($ch, CURLOPT_POST,1);
  curl_setopt($ch, CURLOPT_POSTFIELDS, $influx);
  curl_setopt($ch, CURLOPT_SSLVERSION, 6);
  $result=curl_exec ($ch);
  curl_close ($ch);
}
