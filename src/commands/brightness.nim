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
    govee_device = getDevice(device)

  if "brightness" notin govee_device.supportCmds:
    error "This command is not supported by device ", $device
    return

  # if brightness is default value
  if brightness == -1:  
    let state = getDeviceState(govee_device.device, govee_device.model, apiKey)

    if output:
      echo fmt"Device {device} brightness: {state.brightness}%"

    return state.brightness

  if brightness notin 1..100:
    if output:
      error "Invalid brightness, is not in the range 1-100"

    return

  let body = %* {
    "device": govee_device.device,
    "model": govee_device.model,
    "cmd": {
      "name": "brightness",
      "value": brightness
    }
  }

  let response = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo fmt"Set device {device}'s brightness to {brightness}%"

    sendCompletionMsg response
  
  return brightness
