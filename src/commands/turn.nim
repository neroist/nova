import std/strformat
import std/strutils
import std/json

import puppy

import ../common

func toStr(b: bool): string =
  if b: "on"
  else: "off"

func toggle(str: string): string = 
  if str == "on": "off"
  elif str == "off": "on"
  else: str

func isBool(str: string): bool =
  try: str.parseBool()
  except ValueError: false

proc turn*(device: int = 0; state: string = ""; toggle = false, output = on, all: bool = false): bool =
  ## Turn device on or off

  if not isSetup(output) or (not checkDevices(device, output = output)): return

  if not state.isBool():
    error "Invalid `state`! `state` has to be the string \"off\", \"on\", or something similar."
    return

  if all:
    for i in 0..<numDevices:
      discard turn(i, state, toggle, output)

  var state = state

  let 
    apiKey = readFile(keyFile)
    govee_device = getDevice(device)

  if "turn" notin govee_device.supportCmds:
    error "This command is not supported by device ", $device
    return

  if state == "" and not toggle:
    let state = getDeviceState(govee_device.device, govee_device.model, apiKey)

    if output:
      echo fmt"Device {device} Power state: {state.powerState.toStr()}"

    return state.powerState

  if toggle:
    # warning "We suggest setting the power state manually via `-t`, as this costs an additional API call"

    let device_state = getDeviceState(govee_device.device, govee_device.model, apiKey)

    state = device_state.powerState
                        .toStr()
                        .toggle()

  let body = %* {
    "device": govee_device.device,
    "model": govee_device.model,
    "cmd": {
      "name": "turn",
      "value": state.parseBool().toStr()
    }
  }

  let response = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo &"Set device {device} power state to \"{state}\"\n"

    sendCompletionMsg response

  return state.parseBool()
