## This module contains helper functions so Nova can run properly

#[
  Nova, a program to control Govee light strips from the command line
  Copyright (C) 2023 neroist

  This software is released under the MIT License.
  https://opensource.org/licenses/MIT
]#

import std/httpclient
import std/strformat
import std/terminal
import std/colors
import std/json
import std/math
import std/os

import yanyl

type
  DeviceProperties* = object
    powerState*: bool
    brightness*: int
    colorTemp*: int
    color*: Color

template success*(args: varargs[untyped]) = styledEcho fgGreen, args, resetStyle
template error*(args: varargs[untyped]) = styledEcho fgRed, args, resetStyle

template getDeviceState*(deviceAddr, model, apiKey: string): JsonNode = 
  parseJson(
    fetch(
      &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceAddr, false)}&model={model}",
      @{"Govee-API-Key": apiKey}
    )
  )

func toggle*(str: string): string = 
  if str == "on": "off"
  elif str == "off": "on"
  else: str

func getErrorMsg*(code: int): string =
  case code:
    of 401, 403:
      return "Invalid API key. Run `nova setup` to re-enter your API key."
    of 500..599:
      return "Govee internal error. Try running this command again another time."
    else:
      return $code & " error"

func kelvinToRgb*(temp: int): tuple[r, g, b: range[0..255]] = 
  ## Converts color temperature to rgb
  ## Algorithm from https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
  
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

proc toYaml*(s: Color): YNode =
  newYString("'" & $s & "'")

proc checkDevices*(device: int; numDevices: int; output: bool = on): bool =
  if device notin 0..<numDevices:
    if output:
      error fmt"Invalid device '{device}'. You have {num_devices} device(s)."

    return false
  
  return true

proc isSetup*(output: bool = on; keyDir, devicesDir, errmsg: string): bool =
  ## Checks if Nova is setup properly

  # nested so we don't read from a file that doesnt exist
  if fileExists(keyDir) and fileExists(devicesDir): 
    if "" notin [readFile(keyDir), readFile(devicesDir)]:
      return true
  else:
    if output:
      error errmsg

    return false

proc colorToAnsi*(color: colors.Color; foreground: bool = true): string =
  if not isTrueColorSupported():
    return ""

  result.add '\e'

  let
    rgb = color.extractRGB
    r = rgb.r
    g = rgb.g
    b = rgb.b
    start = if foreground: 38 else: 48

  result.add fmt"[{start};2;{r};{g};{b}m"

proc colorToAnsi*(color: tuple[r, g, b: range[0..255]]; foreground: bool = true): string = 
  colorToAnsi(rgb(color.r, color.g, color.b), foreground)

func getDeviceInfo*(jsonData: JsonNode; device: int): tuple[deviceAddr, model: string] =
  let
    deviceAddr = jsonData[device]["device"].getStr()
    model = jsonData[device]["model"].getStr()

  result = (deviceAddr: deviceAddr, model: model)

proc sendCompletionMsg*(code: int; message: JsonNode; codeMsg: HttpCode) =
  if code == 200:
    success "Successfully executed command"
  else:
    error "Error executing command"
 
  echo "Message: ", message
  echo "Code: ", codeMsg

proc editFileVisibility*(file: string; hidden: bool) =
  ## Edit file visibility of the file `file`. Only edits for Windows and
  ## MacOS, as you can hide a file in linux by simply adding a period before
  ## the file name (and show a file by removing the period).

  var
    winoption = "+h"
    macoption = "hidden"

  if defined(windows) and (not hidden):
    winoption = "-h"
  elif (defined(macos) or defined(macosx)) and (not hidden):
    macoption = "nohidden"

  when defined windows:
    discard execShellCmd(fmt"attrib {winoption} {file}") # add "hidden" attribute to file
  elif defined macos or defined macosx:
    discard execShellCmd(fmt"chflags {macoption} {file}") # set "hidden" flag on file

when isMainModule:
  import std/random

  randomize()

  const Esc = "\e[0m"

  for _ in 0..<150:
    var 
      temp = rand(40000)
      color = kelvinToRgb(temp)
      ccolor = colorToAnsi(rgb(color.r, color.g, color.b))

    echo fmt"color temperature {temp} as {ccolor}rgb({color.r}, {color.g}, {color.b}){Esc}"