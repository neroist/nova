import std/strformat
import std/json
import std/uri

import puppy
import jsony

import ./types
import ./vars

proc getDevice*(device: int, jsonData: string = readFile(devicesFile)): GoveeDevice =
  (jsonData).fromJson(seq[GoveeDevice])[device]

proc getDeviceState*(deviceAddr, model: string; apiKey: string = readFile(keyFile)): DeviceState = 
  (
    let response = parseJson(
      fetch(
        &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceAddr, false)}&model={model}",
        @{"Govee-API-Key": apiKey}
      )
    )
    
    $response["data"]
  ).fromJson(DeviceState)
