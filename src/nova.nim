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
import std/strutils
import std/terminal
import std/browsers
import std/random
import std/colors
import std/sugar
import std/json
import std/uri
import std/os

import tinydialogs
import termui
import cligen
import puppy
#import fidget

import ./helpers


#* NOTE: rgb and color will be 0 if
# 1. music mode is on
# 2. color temperature is not 0
# 3. a scene is playing on the device
# 4. a DIY is playing

# initialize the default random number generator
# becuase some commands need to generate random values
randomize()

# enable true color 
# enableTrueColors()

# globals
var
  numDevices: int
  
const
  DeviceHelp = "The device to perform the action/command on. Defaults to '0'. " &
    "'0' refers to the first device on your account, '1' refers to the second, ect. " &
    "See the full list of devices with `nova devices`." ## "Device" option help text.

  OutputHelp = "Whether or not the command will produce output. " &
    "This also silences errors and will let commands fail silently." ## "Output" option help text.

  NotSetupErrorMsg = "Nova is not setup properly. Use the command `nova setup` to setup Nova." ## Error message when Nova is not setup properly.

  Version = "v1.5.0" ## Nova version

  Description = "Nova is a CLI for controlling Govee light strips based off of Bandev's Lux." ## Nova description

  DevicesURI = "https://developer-api.govee.com/v1/devices" ## The base URI used to get device information.

  ControlURI = DevicesURI & "/control" ## The base URI used to control devices.

  Author = "Jasmine" ## The creator of Nova (me!)

  #[SupportedProperties = [
      "color",
      "rgb",
      "temperature",
      "temp",
      "color-temp"
    ]]#

let
  esc = if isTrueColorSupported(): ansiResetCode
        else: ""

  keyDir = getAppDir() / ".KEY"
  isSetup = (output: bool) => isSetup(output, keyDir, NotSetupErrorMsg) ## shorter method of `isSetup`
  checkDevices = (device: int, output: bool) => checkDevices(device, numDevices, output)

using
  device: int 
  output: bool


# set num_devices
if isSetup(output=false):
  let
    apiKey = readFile(keyDir)
    data = parseJson(
      fetch(
        DevicesURI,
        @{"Govee-API-Key": apiKey}
      )
    )

  numDevices = data["data"]["devices"].getElems().len


# ---- commands ----

proc setup =
  ## Setup Nova
  
  echo "See https://github.com/neroist/Nova#how-to-get-govee-api-key if you dont't have your Govee API key\n"

  let apiKey = termuiAsk "Enter your Govee API key:"

  var
    response = get(DevicesURI, @{"Govee-API-Key": apiKey})
    code = response.code

  if code == 200:
    if fileExists keyDir:
      editFileVisibility(keyDir, hidden=false)

    writeFile(keyDir, apiKey)
    editFileVisibility(keyDir, hidden=true)

    success "\nSetup completed successfully.\nWelcome to Nova."
    return
  else:
    error "\nCode: ", $code
    error getErrorMsg(code)
    return

proc turn(device = 0; state: string = ""; output = on): string =
  ## Turn device on or off

  if not isSetup(output) or (not checkDevices(device, output = output)): return

  let apiKey = readFile(keyDir)

  if state == "":
    let
      resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        fetch(
          fmt"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}",
          @{"Govee-API-Key": apiKey}
        )
      )

    if output:
      echo fmt"Device {device} Power state: ", response["data"]["properties"][1]["powerState"].getStr()

    return response["data"]["properties"][1]["powerState"].getStr()


  let state = state.toLowerAscii()

  if state != "off" and state != "on":
    error "Invalid state, state has to be the string \"off\" or \"on\"."
    return

  let
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  let body = fmt"""
  {{
    "device": "{deviceName}",
    "model": "{model}",
    "cmd": {{
      "name": "turn",
      "value": "{state}"
    }}
  }}
  """

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, body)

  if output:
    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return state

proc color(device = 0; color: string = ""; output = on): string =
  ## Set device color with an HTML/hex color code.
  ## NOTE: when called with no parameters, the device's current color will be #000000 if:
  ## 
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  if not isSetup(output) or not checkDevices(device, output = output): return

  let apiKey = readFile(keyDir)

  var
    color = color.replace(" ").toLowerAscii()
    colorJson: JsonNode
    r: int
    g: int
    b: int

  if color == "":
    let
      resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        fetch(
          fmt"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}",
          @{"Govee-API-Key": apiKey}
        )
      )

    try:
      colorJson = response["data"]["properties"][3]["color"]
    except KeyError:
      colorJson = parseJson("""{"r": 0, "g": 0, "b": 0}""")

    let
      color = $rgb(
        int(colorJson["r"].num), 
        int(colorJson["g"].num), 
        int(colorJson["b"].num)
      )

    if output:
      echo fmt"Device {device} color: ", colorToAnsi(parseColor(color)), color, esc

    return color

  block checks:
    if color != "random" and color != "rand":
      if color.isColor():
        color = $(color).parseColor()
        break checks

      if color[0] != '#': 
        color = '#' & color

      if not color.isColor():
        if output:
          error fmt "{color[1..^1]} is an invalid color."

        return

  let
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  if color == "random" or color == "rand":
    r = rand(255)
    g = rand(255)
    b = rand(255)
  else:
    let rgb = parseColor(color).extractRGB()
    r = rgb[0]
    g = rgb[1]
    b = rgb[2]


  let body = fmt"""
  {{
    "device": "{deviceName}",
    "model": "{model}",
    "cmd": {{
      "name": "color",
      "value": {{
        "r": {r},
        "g": {g},
        "b": {b}
      }}
    }}
  }}
  """

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, body)

  if output:
    echo fmt"Set device {device}'s color to ", colorToAnsi(rgb(r, g, b)), rgb(r, g, b), esc, '\n'
    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return color

proc brightness(device = 0; brightness = -1; output = on): int =
  ## Set device brightness

  if not isSetup(output) or not checkDevices(device, output = output): return

  let apiKey = readFile(keyDir)

  if brightness == -1:  # if brightness is default value
    let
      resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        fetch(
          fmt"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}",
          @{"Govee-API-Key": apiKey}
        )
      )

    if output:
      echo fmt"Device {device} brightness: ", response["data"]["properties"][2]["brightness"].getInt(), '%'

    return response["data"]["properties"][2]["brightness"].getInt()

  if brightness notin 1..100 :
    if output:
      error "Invalid brightness, is not in the range 1-100"

    return

  let
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  let body = fmt"""
  {{
    "device": "{deviceName}",
    "model": "{model}",
    "cmd": {{
      "name": "brightness",
      "value": {brightness}
    }}
  }}
  """

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, body)

  if output:
    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)
  
  return brightness

proc colorTemp(device = 0; output = on; temperature: int = -1): int =
  ## Set device color temperature in kelvin

  if not isSetup(output) or not checkDevices(device, output = output): return

  let apiKey = readFile(keyDir) 

  if temperature <= -1:
    var temp: int

    let
      resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        fetch(
          &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}",
          @{"Govee-API-Key": apiKey}
        )
      )

    try:
      temp = response["data"]["properties"][3]["colorTemInKelvin"].getInt()
    except KeyError:
      temp = 0

    let 
      ccolor = kelvinToRgb(temp)
      ansi = colorToAnsi(ccolor)

    if output:
      echo fmt"Device {device}'s color temperature is {ansi}", temp, 'K', esc

    return temp

  let
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
    jsonColorTemRange = resp["data"]["devices"][device]["properties"]["colorTem"]["range"]
    colorTemRange = [jsonColorTemRange["min"].getInt(), jsonColorTemRange["max"].getInt()]

  if temperature notin colorTemRange[0]..colorTemRange[1]:
    if output:
      error fmt"Color temperature {temperature}K out of supported range: {colorTemRange[0]}K-{colorTemRange[1]}K"

    return

  let
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  let body = fmt"""
  {{
    "device": "{deviceName}",
    "model": "{model}",
    "cmd": {{
      "name": "colorTem",
      "value": {temperature}
    }}
  }}
  """

  let 
    re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, body)

    color = kelvinToRgb(temperature)
    ccolor = colorToAnsi color

  if output:
    echo fmt"Set device {device}'s color temperature to {ccolor}{temperature}K{esc}", '\n'

    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return temperature

proc state(device = 0) =
  ## Output state of device

  if not isSetup(true) or not checkDevices(device, true): return

  let apiKey = readFile(keyDir)

  var
    colorJson: JsonNode
    colorTem: int = 0 

  let
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

    response = parseJson(
      fetch(
        &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName)}&model={model}",
        @{"Govee-API-Key": apiKey}
      )
    )

    properties = response["data"]["properties"]

  try:
    colorJson = properties[3]["color"]
  except KeyError:
    colorTem = properties[4]["colorTem"].getInt()
    colorJson = parseJson("""{"r": 0, "g": 0, "b": 0}""")

  let
    r = colorJson["r"].getInt()
    g = colorJson["g"].getInt()
    b = colorJson["b"].getInt()

    color = fmt"#{r.toHex()[^2..^1]}{g.toHex()[^2..^1]}{b.toHex()[^2..^1]}"
    ansi =  colorToAnsi rgb(r, g, b)
    krgb = kelvinToRgb(colorTem)
    kelvinAnsi = colorToAnsi(krgb)

  styledEcho styleItalic, "DEVICE ", $device
  echo "  Mac Address: ", response["data"]["device"].str[0..^1]
  echo "  Model: ", response["data"]["model"].str[0..^1]
  echo "  Online: ", capitalizeAscii($properties[0]["online"].getBool()), " (may be incorrect)"
  echo "  Power State: ", properties[1]["powerState"].getStr().capitalizeAscii()
  echo "  Brightness: ", properties[2]["brightness"].getInt()
  echo "  Color: ", fmt"{ansi}{color}{esc} or {ansi}rgb({r}, {g}, {b}){esc}"
  echo "  Color Temperature: ", kelvinAnsi, colorTem, esc, " (if not 0, color will be #000000)"

proc rgbCmd(rgb: seq[int]; device = 0; output = on): tuple[r, g, b: int] =
  ## Same as command `color` but uses rgb instead of HTML codes, although it doesn't support random colors.
  ## 
  ## NOTE: when called with no parameters, the device's current color will be rgb(0, 0, 0) if:
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  # named rgb_cli because of name collision with the `colors` module

  if not isSetup(output) or not checkDevices(device, output): return
  let apiKey = readFile(keyDir)

  var rgb = rgb

  if rgb == @[]:
    rgb = @[-1, -1, -1]

  if len(rgb) > 3:
    error "RGB is too long, it can only be of length 3 or less."
    return
  elif len(rgb) < 3:
    for _ in 1..(3-len(rgb)):
      rgb.add 0

  if rgb == @[-1 ,-1, -1]:
    var colorJson: JsonNode

    let
      resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

    let response = parseJson(
      fetch(
        &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}",
        @{"Govee-API-Key": apiKey}
      )
    )

    try:
      colorJson = response["data"]["properties"][3]["color"]
    except KeyError:
      colorJson = json.parseJson("""{"r": 0, "g": 0,"b": 0}""")

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
        error "Invalid value(s)"

      return

  let
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

    color = colorToAnsi rgb(rgb[0], rgb[1], rgb[2])

  let body = fmt"""
  {{
    "device": "{deviceName}",
    "model": "{model}",
    "cmd": {{
      "name": "color",
      "value": {{
        "r": {rgb[0]},
        "g": {rgb[1]},
        "b": {rgb[2]}
      }}
    }}
  }}
  """

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, body)

  if output:
    echo fmt"Set device {device}'s color to {color}rgb({rgb[0]}, {rgb[1]}, {rgb[2]}){esc}", '\n'

    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return (r: rgb[0], g: rgb[1], b: rgb[2])

proc devices =
  ## Get list of devices and their properties

  if not isSetup(true): return

  let
    apiKey = readFile(keyDir)
    resp = parseJson fetch(DevicesURI, @{"Govee-API-Key": apiKey})

  for dev, i in resp["data"]["devices"].getElems():
    var 
      scmd = collect(for i in i["supportCmds"].items(): i.str)
      ## seq of all supported commands of the device

    echo "\e[1m", "DEVICE ", $dev, ansiResetCode
    echo "  Address: ", i["device"].getStr()
    echo "  Model: ", i["model"].getStr()
    echo "  Device Name: ", i["deviceName"].getStr()
    echo "  Controllable: ", capitalizeAscii($(i["controllable"].getBool()))
    echo "  Retrievable: ", capitalizeAscii($(i["retrievable"].getBool()))
    echo "  Supported Commands: ", scmd.join(", "), "\n"

#[
proc view(device = 0; property: string = "color"; output = on) =
  ## View a color property of a device (e.g. color, color-temp)

  proc viewColor(c: colors.Color) = 
    proc draw =
      frame "main":
        box 0, 0, 16777215, 16777215 # same max size as a Qt widget
        fill $c

    startFidget(draw, w=800)
    discard

  case property.toLowerAscii:
    of "color", "rgb":
      viewColor parseColor(color(0, "", false))
    of "temperature", "temp", "color-temp":
      let 
        temp = color_temp(0, output=off)
        gold = kelvinToRgb(temp)

      if temp == 0:
        echo "\e[33m", "Color temperature is 0K, viewing color temp 2000K", ansiResetCode
        sleep 1500

      viewColor rgb(gold.r, gold.b, gold.g)
    else:
      if output:
        error &"The property, \"{property}\" is not supported."
        echo "Supported properties: ", SupportedProperties.join(", ")
]#

proc picker(device = 0; setProperty: bool = true; output = on) = 
  ## Pick a color through a GUI (your OS's default color picker dialog)

  let pickedColor = colorChooser("Pick a color", [rand(0..255).byte, rand(0..255).byte, rand(0..255).byte])

  if output:
    echo "Picked ", colorToAnsi(parseColor(pickedColor.hex)), toUpper pickedColor.hex, esc

  if setProperty:
    if output: echo ""

    discard color(device, pickedColor.hex, output)

proc version =
  ## Get Nova current version

  echo "Nova ", Version

proc about =
  ## Nova about

  echo "Nova ", Version
  echo Description
  echo "Made by ", Author

proc description: string =
  ## Prints Nova's description

  return Description

proc source =
  ## View Nova's source code

  openDefaultBrowser("https://github.com/neroist/Nova/blob/main/nova.nim")

proc repo =
  ## View Nova's GitHub repository

  openDefaultBrowser("https://github.com/neroist/Nova/")

proc license =
  ## View Nova's license

  openDefaultBrowser("https://github.com/neroist/Nova/blob/main/LICENSE")

proc docs =
  ## View Nova's documentation

  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/DOCS.md")


when isMainModule:
  # String consts are cast into strings becuase if I dont it throws an error

  const 
    Commands {.used.} = (
      setup,
      turn,
      nova.color, # name collision so we qualify the cmd
      colorTemp,
      state,
      rgbCmd,
      devices,
      version,
      about,
      repo,
      license,
      docs
    ) ## Full list of all commands. Not used but does help during development

  dispatchMulti(
    [setup],
    [
      turn,
      help = {
        "state": "The state you want to put the device in. Has to be the string \"on\" or \"off.\" " &
          " If left blank, the command will print the current power state of the device.",
        "device": DeviceHelp,
        "output": OutputHelp
      },
      noAutoEcho = true
    ],
    [
      brightness,
      help = {
        "brightness": "The brightness you want to set on the device. Supports values 1-100 only. "&
          "If left blank, the command will print the current brightness of the device.",
        "device": DeviceHelp,
        "output": OutputHelp
      },
      noAutoEcho = true
    ],
    [
      nova.color,
      help = {
        "color": "The color that you want to display on the device. " &
          "Has to be a hex/HTML color code, optionally prefixed with '#', or the string \"rand\" or \"random.\" " &
          "If left blank, will return the current color of the device. " &
          "If `color` is \"rand\" or \"random\" a random color will be displayed on the device",
        "device": DeviceHelp,
        "output": OutputHelp
      },
      noAutoEcho = true
    ],
    [
      colorTemp,
      cmdName = "color-temp",
      help = {
        "temperature": "The color temperature you want to set on the device. " &
          "Has to be in the valid range your Govee device supports.",
        "device": DeviceHelp,
        "output": OutputHelp
      },
      noAutoEcho = true
    ],
    [
      state,
      help = {"device": DeviceHelp}
    ],
    [
      state,
      cmdName = "device",
      doc = "Alias for state",
      help = {"device": DeviceHelp}
    ],
    [
      rgbCmd,
      help = {
        "device": DeviceHelp,
        "rgb": "The color you want to set on the device in an RGB format. " &
          "Has to be 3 numbers seperated by a space. " &
          "If left blank, the command will print the current color in an RGB function.",
        "output": OutputHelp
      },
      noAutoEcho = true,
      cmdName = "rgb"
    ],
    [
      picker,
      help = {
        "device": DeviceHelp,
        "output": OutputHelp,
        "set_property": "Whether or not to set `device`'s color to the color chosen."
      }
    ],
    [devices],
    [version],
    [about],
    [description],
    [source],
    [repo],
    [license],
    [docs]
  )
