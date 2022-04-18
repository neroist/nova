from uri import encodeUrl
from os import fileExists, execShellCmd, getAppDir, sleep
from random import rand, randomize
from termui import termuiAsk

import std/[
  httpclient,
  strformat,
  strutils,
  terminal,
  browsers,
  colors,
  sugar,
  json
]

import cligen

import helpers
import fidget

# NOTE: rgb and color will be 0 if
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
  num_devices: int
  
const
  DeviceHelp = "The device to perform the action/command on. Defaults to '0'. " &
    "'0' refers to the first device on your account, '1' refers to the second, ect. " &
    "See the full list of devices with `nova devices`." ## "Device" option help text.

  OutputHelp = "Whether or not the command will produce output. " &
    "This also silences errors and will make commands fail silently." ## "Output" option help text.

  NotSetupErrorMsg = "Nova is not setup properly. Use the command `nova setup` to setup Nova." ## Error message when
  ## Nova is not setup properly.

  Version = "v1.5.0" ## Nova version

  Description = "Nova is a CLI for controlling Govee light strips based off of Bandev's Lux." ## Nova description

  DevicesURI = "https://developer-api.govee.com/v1/devices/" ## The base URI used to get device information.

  ControlURI = DevicesURI & "control/" ## The base URI used to control devices.

  Author = "Grace" ## The creator of Nova (me!).

  SupportedProperties = [
      "color",
      "rgb",
      "temperature",
      "temp",
      "color-temp"
    ]

  Esc = "\e[0m" ## Escape ANSI code

let
  KeyDir = getAppDir() & "\\.KEY"
  isSetup = (output: bool) => isSetup(output, KeyDir, NotSetupErrorMsg) ## shorter method of `isSetup`
  checkDevices = (device: int, output: bool) => checkDevices(device, num_devices, output)

using
  device: int
  output: bool

# set num_devices
if isSetup(output=false):
  let
    apiKey = readFile(KeyDir)
    data = parseJson(
      newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey})).get(DevicesURI).body
    )

  num_devices = data["data"]["devices"].getElems().len

# ---- commands ----

proc setup =
  ## Setup Nova

  let 
    apiKey = termuiAsk "Enter your Govee API key:"
    client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))

  var
    response: JsonNode
    codeKey: string

  response = json.parseJson(client.get(DevicesURI).body)
  
  try: 
    discard response["code"]
    codeKey = "code"
  except KeyError: 
    codeKey = "status"

  if response[codeKey].getInt() == 200:
    if fileExists KeyDir:
      editFileVisibility(KeyDir, hidden=false)

    writeFile(KeyDir, apiKey)
    editFileVisibility(KeyDir, hidden=true)

    styledEcho fgGreen, "\nSetup completed successfully.\nWelcome to Nova."
    return
  else:
    styledEcho fgRed, "\nCode: ", $response[codeKey]
    styledEcho fgRed, response["message"].getStr()[0..^1], "."
    return

proc turn*(device = 0; state: string = ""; output = on): string =
  ## Turn device on or off

  if not isSetup(output) or (not checkDevices(device, output = output)): return

  let apiKey = readFile(KeyDir)

  if state == "":
    var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
    let
      resp = json.parseJson(client.get(DevicesURI).body)
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        client.get(
          &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}"
        ).body
      )
    if output:
      echo fmt"Device {device} Power state: ", response["data"]["properties"][1]["powerState"].getStr()
    return response["data"]["properties"][1]["powerState"].getStr()

  let state = state.toLowerAscii()

  if state != "off" and state != "on":
    styledEcho fgRed, "Invalid state, state has to be the string \"off\" or \"on\"."
    return

  var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  client.headers = newHttpHeaders({"Govee-API-Key": apiKey, "Content-Type": "application/json"})

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

  let re = client.put(ControlURI, body)

  if output:
    sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

  return state

proc color*(device = 0; color: string = ""; output = on): string =
  ## Set device color with an HTML/hex color code.
  ## NOTE: when called with no parameters, the device's current color will be #000000 if:
  ## 
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  if not isSetup(output) or not checkDevices(device, output = output): return

  let apiKey = readFile(KeyDir)

  var
    color = color.replace(" ").toLowerAscii()
    colorJson: JsonNode
    r: int
    g: int
    b: int

  if color == "":
    let
      client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
      resp = json.parseJson(client.get(DevicesURI).body)
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        client.get(
          &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}"
        ).body
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
      echo fmt"Device {device} color: ", colorToAnsi(parseColor(color)), color, Esc

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
          styledEcho fgRed, fmt "{color[1..^1]} is an invalid color."

        return

  var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  client.headers = newHttpHeaders({"Govee-API-Key": apiKey, "Content-Type": "application/json"})

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

  let re = client.put(ControlURI, body)

  if output:
    echo fmt"Set device {device}'s color to ", colorToAnsi(rgb(r, g, b)), rgb(r, g, b), Esc, '\n'
    sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

  return color

proc brightness*(device = 0; brightness = -1; output = on) : int =
  ## Set device brightness

  if not isSetup(output) or not checkDevices(device, output = output): return

  let apiKey = readFile(KeyDir)

  if brightness == -1:  # if brightness is default value
    var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
    let
      resp = json.parseJson(client.get(DevicesURI).body)
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        client.get(
          &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}"
        ).body
      )
    if output:
      echo fmt"Device {device} brightness: ", response["data"]["properties"][2]["brightness"].getInt(), '%'

    return response["data"]["properties"][2]["brightness"].getInt()

  if brightness notin 1..100 :
    if output:
      styledEcho fgRed, "Invalid brightness, is not in the range [1-100]"

    return

  var
    client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  client.headers = newHttpHeaders({"Govee-API-Key": apiKey, "Content-Type": "application/json"})

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

  let re = client.put(ControlURI, body)

  if output:
    sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()
  else:
    return brightness

proc color_temp*(device = 0; output: bool = on; temperature: int = -1): int =
  ## Set device color temperature in kelvin

  if not isSetup(output) or not checkDevices(device, output = output): return

  let apiKey = readFile(KeyDir) 

  var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))


  if temperature <= -1:
    var temp: int

    let
      resp = json.parseJson(client.get(DevicesURI).body)
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

      response = parseJson(
        client.get(
          &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}"
        ).body
      )

    try:
      temp = response["data"]["properties"][3]["colorTemInKelvin"].getInt()
    except KeyError:
      temp = 0

    let 
      ccolor = kelvinToRgb(temp)
      ansi = colorToAnsi(ccolor)

    if output:
      echo fmt"Device {device}'s color temperature is {ansi}", temp, 'K', Esc

    return temp

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    jsonColorTemRange = resp["data"]["devices"][device]["properties"]["colorTem"]["range"]
    colorTemRange = [jsonColorTemRange["min"].getInt(), jsonColorTemRange["max"].getInt()]

  if temperature notin colorTemRange[0]..colorTemRange[1]:
    if output:
      styledEcho fgRed, fmt"Color temperature {temperature}K out of supported range: {colorTemRange[0]}K-{colorTemRange[1]}K"

    return

  let
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

  # change headers
  client.headers = newHttpHeaders({"Govee-API-Key": apiKey, "Content-Type": "application/json"})

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
    re = client.put(ControlURI, body)

    color = kelvinToRgb(temperature)
    ccolor = colorToAnsi color

  if output:
    echo fmt"Set device {device}'s color temperature to {ccolor}{temperature}K{Esc}", '\n'

    sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

  return temperature

proc state*(device = 0) =
  ## Output state of device

  if not isSetup(true) or not checkDevices(device, true): return

  let apiKey = readFile(KeyDir)

  var
    client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
    colorJson: JsonNode
    colorTem: int = 0 

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]
    response = parseJson(
      client.get(
        &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName)}&model={model}"
      ).body
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

    color = fmt"#{r.toHex()[^2 .. ^1]}{g.toHex()[^2 .. ^1]}{b.toHex()[^2 .. ^1]}"
    ansi =  colorToAnsi rgb(r, g, b)
    krgb = kelvinToRgb(colorTem)
    kelvinAnsi = colorToAnsi(krgb)

  styledEcho styleItalic, "DEVICE ", $device
  echo "  Mac Address: ", response["data"]["device"].str[0..^1]
  echo "  Model: ", response["data"]["model"].str[0..^1]
  echo "  Online: ", capitalizeAscii($properties[0]["online"].getBool()), " (may be incorrect)"
  echo "  Power State: ", properties[1]["powerState"].getStr().capitalizeAscii()
  echo "  Brightness: ", properties[2]["brightness"].getInt()
  echo fmt"  Color: {ansi}{color}{Esc} or {ansi}rgb({r}, {g}, {b}){Esc}"
  echo "  Color Temperature: ", kelvinAnsi, colorTem, Esc, " (if not 0, color will be #000000)"

proc rgb_cli*(rgb: seq[int]; device = 0; output = on): tuple[r, g, b: int] =
  ## Same as command `color` but uses rgb instead of HTML codes, although it doesn't support random colors.
  ## NOTE: when called with no parameters, the device's current color will be rgb(0, 0, 0) if:
  ## 
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## 3. A scene is playing on the device.

  # named rgb_cli because of name collision with the `colors` module

  if not isSetup(output) or not checkDevices(device, output): return
  let apiKey = readFile(KeyDir)

  var rgb = rgb

  if rgb == @[]:
    rgb = @[-1, -1, -1]

  if len(rgb) > 3:
    styledEcho fgRed, "RGB is too long, it can only be of length 3 or less."
    return
  elif len(rgb) < 3:
    for _ in 1..(3-len(rgb)):
      rgb.add 0

  if rgb == @[-1 ,-1, -1]:
    var
      client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
      colorJson: JsonNode
    let
      resp = json.parseJson(client.get(DevicesURI).body)
      info = getDeviceInfo(resp, device)
      deviceName = info[0]
      model = info[1]

    let response = parseJson(
      client.get(
        &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceName, false)}&model={model}"
      ).body
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
      echo fmt"Device {device} color: {color}rgb({r}, {g}, {b}){Esc}"

    return (r: r, g: g, b: b)

  for i in rgb:
    if i < 0 or i > 255:
      if output:
        styledEcho fgRed, "Invalid value(s)"

      return

  var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    info = getDeviceInfo(resp, device)
    deviceName = info[0]
    model = info[1]

    color = colorToAnsi rgb(rgb[0], rgb[1], rgb[2])

  client.headers = newHttpHeaders({"Govee-API-Key": apiKey, "Content-Type": "application/json"})

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

  let re = client.put(ControlURI, body)

  if output:
    echo fmt"Set device {device}'s color to {color}rgb({rgb[0]}, {rgb[1]}, {rgb[2]}){Esc}", '\n'

    sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

  return (r: rgb[0], g: rgb[1], b: rgb[2])

proc devices =
  ## Get list of devices and their properties

  if not isSetup(true): return

  let
    apiKey = readFile(KeyDir)
    client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
    resp = json.parseJson(client.get(DevicesURI).body)

  for dev, i in resp["data"]["devices"].getElems():
    var 
      scmd = collect(for i in i["supportCmds"].items(): i.str)
      ## seq of all supported commands of the device

    echo "\e[1m", "DEVICE ", $dev, Esc
    echo "  Address: ", i["device"].getStr()
    echo "  Model: ", i["model"].getStr()
    echo "  Device Name: ", i["deviceName"].getStr()
    echo "  Controllable: ", capitalizeAscii($(i["controllable"].getBool()))
    echo "  Retrievable: ", capitalizeAscii($(i["retrievable"].getBool()))
    echo "  Supported Commands: ", scmd.join(", "), "\n"

proc view*(device: int = 0; property: string = "color"; output: bool = true) =
  ## View a color property of a device (e.g. color, color-temp)

  proc viewColor(c: colors.Color) = 
    proc draw =
      frame "main":
        box 0, 0, 16777215, 16777215 # same max size as a QT widget
        fill $c

    startFidget(draw, w=800)

  case property.toLowerAscii:
    of "color", "rgb":
      viewColor parseColor(color(0, "", false))
    of "temperature", "temp", "color-temp":
      let 
        temp = color_temp(0, output=off)
        gold = kelvinToRgb(temp)

      if temp == 0:
        echo "\e[33m", "Color temperature is 0K, viewing color temp 2000K", Esc
        sleep 1500

      viewColor rgb(gold.r, gold.b, gold.g)
    else:
      if output:
        styledEcho fgRed, &"The property, \"{property}\" is not supported."
        echo "Supported properties: ", SupportedProperties.join(", ")
      
proc version =
  ## Get Nova current version
  echo "Nova ", Version

proc about =
  ## Nova about
  echo "Nova ", Version
  echo Description
  echo "Made by ", Author

func description: string =
  ## Prints Nova's description
  return Description

proc source =
  ## View Nova's source code
  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/nova.nim")

proc repo =
  ## View Nova's GitHub repository
  openDefaultBrowser("https://github.com/nonimportant/Nova/")

proc license =
  ## View Nova's license
  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/LICENSE")

proc docs =
  ## View Nova's documentation
  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/DOCS.md")

when isMainModule:
  # String consts are cast into strings becuase of a bug that prints out the variable's name
  # instead of its value

  const 
    Commands {.used.} = (
      setup,
      turn,
      nova.color, # name collision so we qualify the cmd
      color_temp,
      state,
      rgb_cli,
      view,
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
      help={
        "state": "The state you want to put the device in. Has to be the string \"on\" or \"off.\" " &
          " If left blank, the command will print the current power state of the device.",
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho=true
    ],
    [
      brightness,
      help={
        "brightness": "The brightness you want to set on the device. Supports values 1-100 only. "&
          "If left blank, the command will print the current brightness of the device.",
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho=true
    ],
    [
      nova.color,
      help={
        "color": "The color that you want to display on the device. " &
          "Has to be a hex/HTML color code, optionally prefixed with '#', or the string \"rand\" or \"random.\" " &
          "If left blank, will return the current color of the device. " &
          "If `color` is \"rand\" or \"random\" a random color will be displayed on the device",
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho=true
    ],
    [
      color_temp,
      cmdName="color-temp",
      help={
        "temperature": "The color temperature you want to set on the device. " &
          "Has to be in the valid range your Govee device supports.",
        "device": $DeviceHelp,
        "output": $OutputHelp
      },
      noAutoEcho=true
    ],
    [
      state,
      help={"device": $DeviceHelp}
    ],
    [
      state,
      cmdName="device",
      doc="Alias for state",
      help={"device": $DeviceHelp}
    ],
    [
      rgb_cli,
      help={
        "device": $DeviceHelp,
        "rgb": "The color you want to set on the device in an RGB format. " &
          "Has to be 3 numbers seperated by a space. " &
          "If left blank, the command will print the current color in an RGB function.",
        "output": $OutputHelp
      },
      noAutoEcho=true,
      cmdName="rgb"
    ],
    [
      view,
      help={
        "device": $DeviceHelp,
        "output": $OutputHelp,
        "property": "The property to view. Supported properties: " & static(SupportedProperties.join(", "))
        # if we dont use static here, it throws an error.
      },
      noAutoEcho=true
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
