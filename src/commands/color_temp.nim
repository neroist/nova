import std/httpclient
import std/strformat
import std/terminal
import std/json
import std/math

import puppy

import ../common

func kelvinToRgb*(temp: int): tuple[r, g, b: range[0..255]] = 
  ## Converts color temperature to rgb

  # Algorithm from https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
  
  let temp = temp.clamp(1000, 40000) / 100

  if temp <= 66:
    result.r = 255
    result.g = int (99.4708025861 * ln(temp) - 161.1195681661).clamp(0.0, 255.0)
  else:
    result.r = int (329.698727446 * (pow(temp - 60, -0.1332047592))).clamp(0.0, 255.0)
    result.g = int (288.1221695283 * (pow(temp - 60, -0.0755148492))).clamp(0.0, 255.0)

  if temp >= 66:
    result.b = 255
  elif temp <= 19:
    result.b = 0
  else:
    result.b = int (138.5177312231 * ln(temp - 10) - 305.0447927307).clamp(0.0, 255.0)

proc colorTemp*(device = 0, temperature: int = -1; output = on, all: bool = false): int =
  ## Set device color temperature in kelvin

  if not isSetup(output) or not checkDevices(device, output = output): return
  
  if all:
    for i in 0..<numDevices-1:
      discard colorTemp(i, temperature, output)

  let 
    apiKey = readFile(keyFile) 
    devices = parseJson readFile(devicesFile)
    (deviceAddr, model) = getDeviceInfo(devices, device)

  if temperature == -1:
    let 
      response = getDeviceState(deviceAddr, model, apiKey)

      temp = response["data"]["properties"][3]["colorTemInKelvin"].getInt(0)

      ansi = colorToAnsi(kelvinToRgb(temp))

    if output:
      echo fmt"Device {device}'s color temperature is ", ansi, temp, 'K', esc

    return temp

  let
    jsonColorTemRange = devices[device]["properties"]["colorTem"]["range"]
    colorTemRange = jsonColorTemRange["min"].getInt() .. jsonColorTemRange["max"].getInt()

  if temperature notin colorTemRange:
    if output:
      # .a is slice lower bound, .b is slice upper bound
      error fmt"Color temperature {temperature}K out of supported range: {colorTemRange.a}K-{colorTemRange.b}K"

    return

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "colorTem",
      "value": temperature
    }
  }

  let 
    re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

    ccolor = colorToAnsi(kelvinToRgb(temperature))

  if output:
    echo fmt"Set device {device}'s color temperature to {ccolor}{temperature}K{esc}", '\n'

    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return temperature
