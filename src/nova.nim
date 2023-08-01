#[
  Nova, a program to control Govee light strips from the command line
  Copyright (C) 2023 neroist

  This software is released under the MIT License.
  https://opensource.org/licenses/MIT
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

import ./helpers

# initialize the default random number generator
# becuase some commands need to generate random values
randomize()

# enable true color, needed so commands look prettyyy
enableTrueColors()

# globals
const
  DeviceHelp = "The device to perform the action/command on. Defaults to '0'. " &
    "'0' refers to the first device on your account, '1' refers to the second, ect. " &
    "See the full list of devices with `nova devices`." ## "Device" option help text.

  OutputHelp = "Whether or not the command will produce output. " &
    "This also silences errors and will allow the command to fail silently." ## "Output" option help text.

  NotSetupErrorMsg = "Nova is not setup properly. Use the command `nova setup` to setup Nova." ## Error message when Nova is not setup properly.

  Version = "v1.7.0" ## Nova version

  Description = "Nova is a CLI for controlling Govee light strips, inspired by Jack Devey's Lux." ## Nova description

  DevicesURI = "https://developer-api.govee.com/v1/devices" ## The base URI used to get device information.

  ControlURI = DevicesURI & "/control" ## The base URI used to control devices.

  Author = "Jasmine" ## The creator of Nova (me!)

var
  numDevices: int

let
  esc = if isTrueColorSupported(): ansiResetCode
        else: ""

  # TODO change these variable names 
  keyDir = getAppDir() / ".KEY"
  devicesDir = getAppDir() / ".DEVICES"
  isSetup = (output: bool) => isSetup(output, keyDir, devicesDir, NotSetupErrorMsg) ## shorter method of `isSetup`
  checkDevices = (device: int, output: bool) => checkDevices(device, numDevices, output)

# set numDevices
if isSetup(output=false):
  numDevices = parseJson(readFile(devicesDir)).getElems().len

# ---- commands ----

proc setup =
  ## Setup Nova
  
  echo "See https://github.com/neroist/Nova#how-to-get-govee-api-key if you dont't have your Govee API key\n"

  let apiKey = termuiAsk "Enter your Govee API key:"

  #// maybe just remove this part and to just print the success msg? 
  # nvm, lets take this opportunity to cache the list of the devices 
  let
    response = get(DevicesURI, @{"Govee-API-Key": apiKey})
    code = response.code

  if code == 200:
    # we "un-hide" the the .KEY file incase it exists already because
    # we cant write to a hidden file, apparently
    if fileExists keyDir:
      editFileVisibility(keyDir, hidden=false)

    # same for .DEVICES
    if fileExists devicesDir:
      editFileVisibility(devicesDir, hidden=false)

    writeFile(keyDir, apiKey) # write api key
    writeFile(devicesDir, $parseJson(response.body)["data"]["devices"]) # cache devices

    for file in [keyDir, devicesDir]:
      editFileVisibility(file, hidden=true)

    success "\nSetup completed successfully.\nWelcome to Nova."
    return
  else:
    error "\nCode: ", $code
    error getErrorMsg(code)
    return

proc turn(device = 0; state: string = ""; toggle: bool = false, output = on): string =
  ## Turn device on or off

  if not isSetup(output) or (not checkDevices(device, output = output)): return

  let apiKey = readFile(keyDir)

  let
    resp = parseJson readFile(devicesDir)
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

proc color(device = 0; color: string = ""; output = on): string =
  ## Set device color with an HTML/hex color code.
  ## NOTE: when called with no parameters, the device's current color will be #000000 if:
  ## 
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  if not isSetup(output) or not checkDevices(device, output = output): return

  let 
    apiKey = readFile(keyDir)
    devices = parseJson readFile(devicesDir)
    (deviceAddr, model) = getDeviceInfo(devices, device)

  var
    color = color.replace(" ").replace("-").normalize()
    colorJson = %* {"r": 0, "g": 0, "b": 0}
    r, g, b: int

  if color == "":
    let response = getDeviceState(deviceAddr, model, apiKey)

    try:
      colorJson = response["data"]["properties"][3]["color"]
    except CatchableError: discard

    let
      color = $rgb(
        colorJson["r"].getInt(), 
        colorJson["g"].getInt(), 
        colorJson["b"].getInt()
      )

    if output:
      echo fmt"Device {device} color: ", colorToAnsi(parseColor(color)), color, esc

    return color

  block checks:
    if color notin ["random", "rand"]:
      if color.isColor():
        color = $(color).parseColor()
        break checks

      if color[0] != '#': 
        color = '#' & color

      if not color.isColor():
        if output:
          error fmt"{color[1..^1]} is an invalid color."


  if color in ["random", "rand"]:
    r = rand(255)
    g = rand(255)
    b = rand(255)
  else:
    let rgb = parseColor(color).extractRGB()
    r = rgb[0]
    g = rgb[1]
    b = rgb[2]

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "color",
      "value": {
        "r": r,
        "g": g,
        "b": b
      }
    }
  }

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    echo fmt"Set device {device}'s color to ", colorToAnsi(rgb(r, g, b)), rgb(r, g, b), esc, '\n'
    
    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)

  return color

proc brightness(device = 0; brightness = -1; output = on): int =
  ## Set device brightness

  if not isSetup(output) or not checkDevices(device, output = output): return

  let 
    apiKey = readFile(keyDir)
    devices = parseJson readFile(devicesDir)
    (deviceAddr, model) = getDeviceInfo(devices, device)

  if brightness == -1:  # if brightness is default value
    let response = getDeviceState(deviceAddr, model, apiKey)

    if output:
      echo fmt"Device {device} brightness: ", response["data"]["properties"][2]["brightness"].getInt(), '%'

    return response["data"]["properties"][2]["brightness"].getInt()

  if brightness notin 1..100 :
    if output:
      error "Invalid brightness, is not in the range 1-100"

    return

  let body = %* {
    "device": deviceAddr,
    "model": model,
    "cmd": {
      "name": "brightness",
      "value": brightness
    }
  }

  let re = put(ControlURI, @{"Govee-API-Key": apiKey, "Content-Type": "application/json"}, $body)

  if output:
    sendCompletionMsg re.code, parseJson(re.body)["message"], HttpCode(re.code)
  
  return brightness

proc colorTemp(device = 0; output = on; temperature: int = -1): int =
  ## Set device color temperature in kelvin

  if not isSetup(output) or not checkDevices(device, output = output): return

  let 
    apiKey = readFile(keyDir) 
    devices = parseJson readFile(devicesDir)
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

proc state(device = 0) =
  ## Output state of device

  if not isSetup(true) or not checkDevices(device, true): return

  var
    colorJson = %* {"r": 0, "g": 0, "b": 0}
    colorTem = 0 

  let
    apiKey = readFile(keyDir)
    devices = parseJson readFile(devicesDir)
    (deviceAddr, model) = getDeviceInfo(devices, device)

    response = getDeviceState(deviceAddr, model, apiKey)

    properties = response["data"]["properties"]

  try:
    colorJson = properties[3]["color"]
  except KeyError:
    colorTem = properties[4]["colorTem"].getInt()

  let
    r = colorJson["r"].getInt()
    g = colorJson["g"].getInt()
    b = colorJson["b"].getInt()

    color = fmt"#{r.toHex()[^2..^1]}{g.toHex()[^2..^1]}{b.toHex()[^2..^1]}"
    ansi = colorToAnsi rgb(r, g, b)
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

proc rgbCmd(rgb: seq[int] = @[-1, -1, -1]; device = 0; output = on): tuple[r, g, b: int] =
  ## Same as command `color` but uses rgb instead of HTML codes, although it doesn't support random colors.
  ## 
  ## NOTE: when called with no parameters, the device's current color will be rgb(0, 0, 0) if:
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  # named rgb_cli because of name collision with the `colors` module

  if not isSetup(output) or not checkDevices(device, output): return

  var rgb = rgb

  if len(rgb) != 3:
    error "RGB has to be 3 integers, no more, no less."
    return

  let
    apiKey = readFile(keyDir)
    devices = parseJson readFile(devicesDir)
    (deviceAddr, model) = getDeviceInfo(devices, device)

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

proc devices =
  ## Get list of devices and their properties

  if not isSetup(true): return

  let devices = parseJson readFile(devicesDir) 

  for dev, i in devices.getElems():
    let 
      cmds = collect(for i in i["supportCmds"]: i.getStr())
      ## seq of all supported commands of the device

    echo "\e[1m", "DEVICE ", $dev, ansiResetCode
    echo "  Mac Address: ", i["device"].getStr()
    echo "  Model: ", i["model"].getStr()
    echo "  Device Name: ", i["deviceName"].getStr()
    echo "  Controllable: ", capitalizeAscii($(i["controllable"].getBool()))
    echo "  Retrievable: ", capitalizeAscii($(i["retrievable"].getBool()))
    echo "  Supported Commands: ", cmds.join(", "), "\n"

proc picker(device = 0; setProperty: bool = true; output = on) = 
  ## Pick a color through a GUI (your OS's default color picker dialog)

  let 
    pickedColor = colorChooser(
      "Pick a color", 
      [rand(0..255).byte, rand(0..255).byte, rand(0..255).byte]
    )

  if output:
    echo "Picked ", colorToAnsi(parseColor(pickedColor.hex)), toUpper pickedColor.hex, esc

  if setProperty:
    if output: echo ""

    discard color(device, pickedColor.hex, output)

proc update(output = on) = 
  ## Update the cached list of devices. Run whenever a new device is added
  ## or modified.
  
  let
    apiKey = readFile(keyDir) 
    response = fetch(DevicesURI, @{"Govee-API-Key": apiKey})
  
  editFileVisibility(devicesDir, false)

  writeFile(devicesDir, $parseJson(response)["data"]["devices"])

  editFileVisibility(devicesDir, true)

  if output:
    success "Successfully updated devices! ✔️" # not all terminal support emojis...

proc version =
  ## Get Nova current version

  echo "Nova ", Version

proc about =
  ## Nova about

  echo "Nova ", Version, '\n'
  echo Description
  echo "Made by ", Author, '.'

proc description: string =
  ## Prints Nova's description

  return Description

proc source =
  ## View Nova's source code

  openDefaultBrowser("https://github.com/neroist/nova/blob/main/nova.nim")

proc repo =
  ## View Nova's GitHub repository

  openDefaultBrowser("https://github.com/neroist/nova/")

proc license(browser: bool = false) =
  ## View Nova's license
  
  if browser:
    openDefaultBrowser("https://github.com/neroist/nova/blob/main/LICENSE")
  else:
    echo fetch("https://raw.githubusercontent.com/neroist/nova/main/LICENSE")

proc docs =
  ## View Nova's documentation

  openDefaultBrowser("https://neroist.github.io/nova/")


when isMainModule:
  clCfg.version = "Nova " & Version

  # String consts are cast into strings becuase if I dont it throws an error
  # or prints out the name of the const
  dispatchMulti(
    [setup],
    [
      turn,
      help = {
        "state": "The state you want to put the device in. Has to be the string \"on\" or \"off.\" " &
                 "If left blank, the command will print the current power state of the device.",
        "toggle": "Whether or not to toggle the power state of the device (if its on turn it off and " &
                  "vice-versa). This flag takes precedence over the `state` option.",
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho = true
    ],
    [
      brightness,
      help = {
        "brightness": "The brightness you want to set on the device. Supports values 1-100 only. " &
                      "If left blank, the command will print the current brightness of the device.",
        "device": $DeviceHelp,
        "output": $OutputHelp
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
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho = true
    ],
    [
      colorTemp,
      cmdName = "color-temp",
      help = {
        "temperature": "The color temperature you want to set on the device. " &
                       "Has to be in the valid range your Govee device supports.",
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho = true
    ],
    [
      state,
      help = {"device": $DeviceHelp}
    ],
    [
      state,
      cmdName = "device",
      doc = "Alias for state",
      help = {"device": $DeviceHelp}
    ],
    [
      rgbCmd,
      help = {
        "device": $DeviceHelp,
        "rgb": "The color you want to set on the device in an RGB format. " &
               "Has to be 3 numbers seperated by a space. " &
               "If left blank, the command will print the current color in an RGB function.",
        "output": $OutputHelp
      },
      noAutoEcho = true,
      cmdName = "rgb"
    ],
    [
      picker,
      help = {
        "device": $DeviceHelp,
        "output": $OutputHelp,
        "set_property": "Whether or not to set `device`'s color to the color chosen."
      }
    ],
    [
      nova.update,
      help = {
        "output": $OutputHelp
      }
    ],
    [devices],
    [version],
    [about],
    [description],
    [source],
    [repo],
    [
      license,
      help = {
        "browser": "Whether or not to open the license in the default " &
                   "browser, or to just print the license text to the terminal"
      }
    ],
    [docs]
  )
