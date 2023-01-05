## This module contains helper functions so Nova can run properly

#[

  Nova, a program to control Govee light strips from the command line
  Copyright (C) 2023 Jasmine

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.

]#

import std/httpclient
import std/strformat
import std/terminal
import std/colors
import std/json
import std/math
import std/os

using
  device: int
  output: bool


template success*(args: varargs[untyped]) = styledEcho fgGreen, args, resetStyle
template error*(args: varargs[untyped]) = styledEcho fgRed, args, resetStyle

func getErrorMsg*(code: int): string =
  case code:
    of 403:
      return "Invalid API key. Run `nova setup` to re-enter your API key."
    of 500..599:
      return "Govee internal error. Try running this command again another time."
    else:
      return "OK"

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

proc checkDevices*(device; num_devices: int; output: bool = on): bool =
  if device notin 0 ..< num_devices:
    if output:
      styledEcho fgRed, fmt"Invalid device '{device}'. You have {num_devices} device(s)."

    return false
  
  return true

proc isSetup*(output: bool = on; keydir, errmsg: string): bool =
  ## Checks if Nova is setup properly

  if fileExists(keyDir):
    if readFile(keyDir) != "":
      return true
  else:
    if output:
      styledEcho fgRed, errmsg

    return false

func colorToAnsi*(color: colors.Color; foreground: bool = true): string =
  result.add '\e'

  let
    rgb = color.extractRGB
    r = rgb.r
    g = rgb.g
    b = rgb.b
    start = if foreground: 38 else: 48

  result.add fmt"[{start};2;{r};{g};{b}m"

func colorToAnsi*(color: tuple[r, g, b: range[0..255]]; foreground: bool = true): string = 
  colorToAnsi(rgb(color.r, color.g, color.b), foreground)

func getDeviceInfo*(jsonData: JsonNode; device): tuple[deviceName, model: string] =
  let
    deviceName = jsonData["data"]["devices"][device]["device"].getStr()
    model = jsonData["data"]["devices"][device]["model"].getStr()

  result = (deviceName: deviceName, model: model)

proc sendCompletionMsg*(code: int; message: JsonNode; codeMsg: HttpCode) =
  if code == 200:
    styledEcho fgGreen, "Successfully executed command"
  else:
    styledEcho fgRed, "Error executing command"
 
  echo "Message: ", message
  echo "Code: ", codeMsg

proc editFileVisibility*(file: string; hidden: bool) =
  var
    winoption = "+h"
    macoption = "hidden"

  if defined(windows) and (not hidden):
    winoption = "-h"
  elif (defined(macos) or defined(macosx)) and (not hidden):
    macoption = "nohidden"

  when defined windows:
    discard execShellCmd(fmt"attrib {winoption} {file}") # add "hidden" attribute to file
  elif defined macos:
    discard execShellCmd(fmt"chflags {macoption} {file}") # set "hidden" flag on file
  elif defined macosx:
    discard execShellCmd(fmt"chflags {macoption} {file}") # same as above


when isMainModule:
  import std/random

  randomize()

  const Esc = "\e[0m"

  for _ in 0..<150:
    var 
      temp = rand(40000)
      color = kelvinToRgb(temp)
      ccolor = colorToAnsi(rgb(color.r, color.g, color.b))

    echo fmt"color temperature {ccolor}{temp}{Esc} as {ccolor}rgb({color.r}, {color.g}, {color.b}){Esc}"