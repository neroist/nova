import std/httpclient
import std/strformat
import std/strutils
import std/json

import puppy

import ../common

func toStr(b: bool): string =
  if b == true: "on"
  else: "off"

func toggle(str: string): string = 
  if str == "on": "off"
  elif str == "off": "on"
  else: str

proc turn*(device: int = 0; state: string = ""; toggle = false, output = on, all: bool = false): string =
  ## Turn device on or off

  if not isSetup(output) or (not checkDevices(device, output = output)): return

  if all:
    for i in 0..<numDevices-1:
      discard turn(i, state, toggle, output)

  let 
    apiKey = readFile(keyFile)

    devices = parseFile(devicesFile)
    (deviceAddr, model) = getDeviceInfo(devices, device)

  if newJString("turn") notin devices[device]["supportCmds"].getElems():
    error "This command is not supported by device ", $device
    return

  var state = state

  if state == "" and not toggle:
    let response = getDeviceState(deviceAddr, model, apiKey)

    if output:
      echo fmt"Device {device} Power state: ", response["data"]["properties"][1]["powerState"].getStr()

    return response["data"]["properties"][1]["powerState"].getStr()

  if toggle:
    let response = getDeviceState(deviceAddr, model, apiKey)

    state = response["data"]["properties"][1]["powerState"].getStr().toggle()

  try: discard state.parseBool()
  except ValueError:
    error "Invalid state, state has to be the string \"off\", \"on\", or something similar."
    return

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "turn",
      "value": state.parseBool().toStr()
    }
  }

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo &"Set device {device} power state to \'", state, "\'"
    echo ""

    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return state
