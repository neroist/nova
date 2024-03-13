import std/httpclient
import std/strformat
import std/terminal
import std/json

import puppy

import ../common

proc brightness*(device = 0, brightness: int = -1; output = on, all: bool = false): int =
  ## Set device brightness

  if not isSetup(output) or not checkDevices(device, output = output): return
  
  if all:
    for i in 0..<numDevices-1:
      discard brightness(i, brightness, output)

  let 
    apiKey = readFile(keyFile)
    devices = parseJson readFile(devicesFile)
    (deviceAddr, model) = getDeviceInfo(devices, device)

  if brightness == -1:  # if brightness is default value
    let response = getDeviceState(deviceAddr, model, apiKey)

    if output:
      echo fmt"Device {device} brightness: ", response["data"]["properties"][2]["brightness"].getInt(), '%'

    return response["data"]["properties"][2]["brightness"].getInt()

  if brightness notin 1..100 :
    if output:
      error "Invalid brightness, is not in the range 1-100"

    return

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "brightness",
      "value": brightness
    }
  }

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)
  
  return brightness
