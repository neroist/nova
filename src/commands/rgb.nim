import std/httpclient
import std/strformat
import std/terminal
import std/colors
import std/json

import puppy

import ../common

proc rgb*(rgb: seq[int] = @[-1, -1, -1]; device: int = 0; output = on, all: bool = false): tuple[r, g, b: int] =
  ## Same as command `color` but uses rgb instead of HTML codes, although it doesn't support random colors.
  ## 
  ## NOTE: when called with no parameters, the device's current color will be rgb(0, 0, 0) if:
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  if not isSetup(output) or not checkDevices(device, output=output): return

  if all:
    for i in 0..<numDevices:
      discard rgb(rgb, i, output)

  var rgb = rgb

  if len(rgb) != 3:
    error "RGB has to be 3 integers, no more, no less."
    return

  let
    apiKey = readFile(keyFile)
    devices = parseJson readFile(devicesFile)
    (deviceAddr, model) = getDeviceInfo(devices, device)

  if newJString("color") notin devices[device]["supportCmds"].getElems():
    error "This command is not supported by device ", $device
    return

  if rgb == @[-1 ,-1, -1]:
    var colorJson = %* {"r": 0, "g": 0, "b": 0}

    let response = getDeviceState(deviceAddr, model, apiKey)

    try:
      colorJson = response["data"]["properties"][3]["color"]
    except KeyError:
      discard

    let 
      r = colorJson["r"].getInt()
      g = colorJson["g"].getInt()
      b = colorJson["b"].getInt()

      color = colorToAnsi rgb(r, g, b)

    if output:
      echo fmt"Device {device} color: {color}rgb({r}, {g}, {b}){esc}"

    return (r: r, g: g, b: b)

  for i in rgb:
    if i notin 1..255:
      if output:
        error "Invalid value: ", $i, " not in range 1-255"

      return

  let
    color = colorToAnsi rgb(rgb[0], rgb[1], rgb[2])

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "color",
      "value": {
        "r": rgb[0],
        "g": rgb[1],
        "b": rgb[2]
      }
    }
  }

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo fmt"Set device {device}'s color to {color}rgb({rgb[0]}, {rgb[1]}, {rgb[2]}){esc}", '\n'

    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return (r: rgb[0], g: rgb[1], b: rgb[2])
