import std/httpclient
import std/strformat
import std/json

import puppy

import ../common

func toggle*(str: string): string = 
  if str == "on": "off"
  elif str == "off": "on"
  else: str

proc turn*(device: int = 0; state: string = ""; toggle: bool = false, output: bool = on): string =
  ## Turn device on or off

  if not isSetup(output) or (not checkDevices(device, output = output)): return

  let apiKey = readFile(keyFile)

  let
    resp = parseJson readFile(devicesFile)
    (deviceAddr, model) = getDeviceInfo(resp, device)

  var state = state

  if state == "" and not toggle:
    let response = getDeviceState(deviceAddr, model, apiKey)

    if output:
      echo fmt"Device {device} Power state: ", response["data"]["properties"][1]["powerState"].getStr()

    return response["data"]["properties"][1]["powerState"].getStr()

  if toggle:
    let response = getDeviceState(deviceAddr, model, apiKey)

    state = response["data"]["properties"][1]["powerState"].getStr().toggle()

  if state notin ["off", "on"]:
    error "Invalid state, state has to be the string \"off\" or \"on\"."
    return

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "turn",
      "value": state
    }
  }

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo "Set device power state to \'", state, "\'"
    echo ""

    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return state
