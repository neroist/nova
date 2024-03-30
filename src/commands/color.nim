import std/strformat
import std/strutils
import std/terminal
import std/random
import std/colors
import std/json

import puppy

import ../common

proc color*(device: int = 0; color: string = ""; output = on, all: bool = false): string =
  ## Set device color with an HTML/hex color code.
  ## 
  ## NOTE: when called with no parameters, the device's current color will be #000000 if:
  ## 
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  if not isSetup(output) or not checkDevices(device, output = output): return
  
  if all:
    for i in 0..<numDevices-1:
      discard color(i, color, output)
  
  let 
    apiKey = readFile(keyFile)
    govee_device = getDevice(device)

  if "color" notin govee_device.supportCmds:
    error "This command is not supported by device ", $device
    return

  var
    color = color.replace(" ").replace("-").normalize()
    r, g, b: int

  if color == "":
    let state = getDeviceState(govee_device.device, govee_device.model, apiKey)

    if output:
      echo fmt"Device {device} color: ", colorToAnsi(state.color), state.color, esc

    return color

  block checks:
    if color notin ["random", "rand"]:
      if color.isColor():
        color = $color.parseColor()
        break checks

      if color[0] != '#': 
        color = '#' & color

      if not color.isColor():
        if output:
          error fmt"{color[1..^1]} is an invalid color."

        return

  if color in ["random", "rand"]:
    r = rand(255)
    g = rand(255)
    b = rand(255)
  else:
    (r, g, b) = parseColor(color).extractRGB()

  let body = %* {
    "device": govee_device.device,
    "model": govee_device.model,
    "cmd": {
      "name": "color",
      "value": {
        "r": r,
        "g": g,
        "b": b
      }
    }
  }

  let response = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo fmt"Set device {device}'s color to {colorToAnsi(rgb(r, g, b))}{rgb(r, g, b)}{esc}", '\n'
    
    sendCompletionMsg response

  return color
