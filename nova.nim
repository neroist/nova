from uri import encodeUrl
from os import fileExists, execShellCmd, getAppDir
from random import rand, randomize
import cligen
import httpclient
import json
import strformat
import strutils
import terminal
import browsers
from colors import parseColor, isColor, extractRGB, `$`

# NOTE: rgb and color will be 0 if
# 1. music mode is on
# 2. color temperature is not 0
# 3. a scene is playing on the device
# 4. a DIY is playing

# initialize the default random number generator
randomize()

# enable true color
enableTrueColors()

# forward declarations
proc isSetup(echoMsg: bool = true): bool

# globals
var
  num_devices: int

let
  KeyDir = getAppDir() & "\\.KEY"
  
const
  DeviceHelp = "The device to perform the action/command on. Defaults to '0'." &
  "'0' refers to the first device on your account, '1' refers to the second, ect. " &
  "See the full list of devices with `nova devices`."
  NotSetupErrorMsg = "Nova is not setup properly. Use the command `nova setup` to setup Nova."
  Version = "v1.2.0"
  Description = "Nova is a CLI for controlling Govee light strips based off of Bandev's Lux."
  DevicesURI = "https://developer-api.govee.com/v1/devices"
  ControlURI = DevicesURI & "/control"
  Author = "Alice/Grace"

# set num_devices
if isSetup(echoMsg=false):
  let
    apiKey = readFile(KeyDir)
    data = parseJson(
      newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey})).get(DevicesURI).body
    )

  num_devices = data["data"]["devices"].getElems().len()

# non-command procs
proc getDeviceInfo(jsonData: JsonNode, device: int): array[2, string] =
  let
    deviceName = jsonData["data"]["devices"][device]["device"].getStr()
    model = jsonData["data"]["devices"][device]["model"].getStr()

  result = [deviceName, model]

proc isSetup(echoMsg: bool = true): bool =
  if fileExists(KeyDir):
    if readFile(KeyDir) != "":
      return true
  else:
    if echoMsg:
      styledEcho fgRed, NotSetupErrorMsg
    return false

proc sendCompletionMsg(code: int, message: JsonNode, code_msg: HttpCode) =
  if code == 200:
    styledEcho fgGreen, "Successfully executed command"
  else:
    styledEcho fgRed, "Error executing command"
 
  echo "Message: ", message
  echo "Code: ", code_msg

proc checkDevices(device: int): bool = 
  if device notin 0 ..< num_devices:
    styledEcho fgRed, fmt"Invalid device '{device}'. You have {num_devices} device(s)."
    return false
  
  return true

# commands
proc setup() =
  ## Setup Nova

  echo "Enter Govee API Key:"
  let 
    apiKey = readLine(stdin)
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
    writeFile(KeyDir, apiKey)
    styledEcho fgGreen, "\nSetup completed successfully.\nWelcome to Nova."

    when defined windows:
      discard execShellCmd(fmt"attrib -r +h {KeyDir}") # remove "read-only" attribute and add "hidden" attribute
    elif defined macos:
      discard execShellCmd(fmt"chflags hidden {KeyDir}") # set "hidden" flag on file
    elif defined macosx:
        discard execShellCmd(fmt"chflags hidden {KeyDir}") # same as above
    return
  else:
    styledEcho fgRed, "\nCode: ", $response[codeKey]
    styledEcho fgRed, response["message"].getStr()[0..^1], "."
    return

proc turn(device: int = 0, state: string = "") =
  ## Turn device on or off

  if not isSetup() or not checkDevices(device): return

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

    echo fmt"Device {device} Power state: ", response["data"]["properties"][1]["powerState"].getStr()
    return

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

  sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

proc color(device: int = 0, color: string = "") =
  ## Set device color with an HTML/hex color code.
  ## NOTE: when called with no parameters, the device's current color will be #000000 if:
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## or 3. A scene is playing on the device.

  if not isSetup() or not checkDevices(device): return

  let apiKey = readFile(KeyDir)

  var
    color = color.replace(" ").toLowerAscii()
    colorJson: JsonNode
    r: int
    g: int
    b: int

  if color == "":
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

    try:
      colorJson = response["data"]["properties"][3]["color"]
    except KeyError:
      colorJson = parseJson("""{"r": 0, "g": 0, "b": 0}""")
    let
      color = '#' & $colorJson["r"].getInt().toHex()[^2 .. ^1] &
        $colorJson["g"].getInt().toHex()[^2 .. ^1] &
        $colorJson["b"].getInt().toHex()[^2 .. ^1]

    echo fmt"Device {device} color: ", color
    return

  block checks:
    if color != "random" and color != "rand":
      if color.isColor():
        color = $(color).parseColor()
        break checks

      if color[0] != '#': 
        color = '#' & color

      if not color.isColor():
        styledEcho fgRed, fmt "{color} is an invalid color."
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

  sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

proc brightness(device = 0, brightness: int = -1) =
  ## Set device brightness

  if not isSetup() or not checkDevices(device): return

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

    echo fmt"Device {device} brightness: ", response["data"]["properties"][2]["brightness"].getInt()
    return

  if brightness > 100 or brightness < 1:
    styledEcho fgRed, "Invalid brightness, is not in the range [1-100]"
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
      "name": "brightness",
      "value": {brightness}
    }}
  }}
  """

  let re = client.put(ControlURI, body)

  sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

proc color_tem(device = 0, temperature: int) =
  ## Set device color temperature

  if not isSetup() or not checkDevices(device): return

  let apiKey = readFile(KeyDir)

  var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))

  let
    resp = json.parseJson(client.get(DevicesURI).body)
    jsonColorTemRange = resp["data"]["devices"][device]["properties"]["colorTem"]["range"]
    colorTemRange = [jsonColorTemRange["min"].getInt(), jsonColorTemRange["max"].getInt()]

  if temperature notin colorTemRange[0]..colorTemRange[1]:
    styledEcho fgRed, fmt"Color temperature ({temperature}) out of supported range: {colorTemRange[0]}-{colorTemRange[1]}"
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

  let re = client.put(ControlURI, body)

  sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

proc state(device: int = 0) =
  ## Return state of device

  if not isSetup() or not checkDevices(device): return

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

  styledEcho styleItalic, "DEVICE ", $device
  echo "  Mac Address: ", response["data"]["device"]
  echo "  Model: ", response["data"]["model"]
  echo "  Online: ", capitalizeAscii($properties[0]["online"].getBool()), " (may be incorrect)"
  echo "  Power State: ", properties[1]["powerState"].getStr().capitalizeAscii()
  echo "  Brightness: ", properties[2]["brightness"].getInt()
  echo fmt"  Color: {color} or rgb({r}, {g}, {b})"
  echo "  Color Temperature: ", colorTem, " (if not 0, color will be #000000)"

proc rgb(rgb: seq[int], device: int = 0) =
  ## Same as command `color` but uses rgb instead of HTML codes, although it doesn't support random colors.
  ## NOTE: when called with no parameters, the device's current color will be rgb(0, 0, 0) if:
  ## 1. Music mode is on. 
  ## 2. color temperature is not 0. 
  ## or 3. A scene is playing on the device.

  if not isSetup() or not checkDevices(device): return
  let apiKey = readFile(KeyDir)

  var rgb = rgb

  if rgb == @[]:
    rgb = @[-1, -1, -1]

  if len(rgb) > 3:
    styledEcho fgRed, "RGB is too long, it can only be of length 3 or less."
    return
  elif len(rgb) < 3:
    for i in 1..(3-len(rgb)):
      rgb.add(0)

  if rgb == [-1 ,-1, -1]:
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

    let r = colorJson["r"].getInt()
    let g = colorJson["g"].getInt()
    let b = colorJson["b"].getInt()

    echo fmt"Device {device} color: rgb({r}, {g}, {b})"
    return

  for i in rgb:
    if i < 0 or i > 255:
      styledEcho fgRed, "Invalid value(s)"
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

  sendCompletionMsg int(re.code()), parseJson(re.body())["message"], re.code()

proc devices() =
  ## Get list of devices and their properties

  if not isSetup(): return

  let apiKey = readFile(KeyDir)

  var client = newHttpClient(headers=newHttpHeaders({"Govee-API-Key": apiKey}))
  let resp = json.parseJson(client.get(DevicesURI).body)

  for dev, i in resp["data"]["devices"].getElems():
    var scmd: seq[string]

    for i in i["supportCmds"].items():
      scmd.add(i.getStr())

    styledEcho styleItalic, "DEVICE ", $dev
    echo "  Address: ", i["device"].getStr()
    echo "  Model: ", i["model"].getStr()
    echo "  Device Name: ", i["deviceName"].getStr()
    echo "  Controllable: ", capitalizeAscii($(i["controllable"].getBool()))
    echo "  Retrievable: ", capitalizeAscii($(i["retrievable"].getBool()))
    echo "  Supported Commands: ", scmd.join(", ")

    echo ""

proc device(device: int = 0) =
  ## Alias for `state`
  state(device)

proc version() =
  ## Get Nova current version
  echo "Nova version ", Version

proc about() =
  ## Nova about
  echo "Nova ", Version
  echo Description
  echo "Made by ", Author

proc description() =
  ## Prints Nova's description
  echo Description

proc source() =
  ## View Nova's source code
  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/nova.nim")

proc repo() =
  ## View Nova's GitHub repository
  openDefaultBrowser("https://github.com/nonimportant/Nova/")

proc license() =
  ## View Nova's license

  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/LICENSE")

proc docs() =
  ## View Nova's documentation
  openDefaultBrowser("https://github.com/nonimportant/Nova/blob/main/DOCS.md")


dispatchMulti(
  [setup],
  [
    turn,
    help={
      "state": "The state you want to put the device in. Has to be the string \"on\" or \"off.\" " &
        " If left blank, the command will print the current power state of the device.",
      "device": $DeviceHelp
    }
  ],
  [
    brightness,
    help={
      "brightness": "The brightness you want to set on the device. Supports values 1-100 only. "&
        "If left blank, the command will print the current brightness of the device.",
      "device": $DeviceHelp
    }
  ],
  [
    color,
    help={
      "color": "The color that you want to display on the device. " &
        "Has to be a hex/HTML color code, optionally prefixed with '#', or the string \"rand\" or \"random.\" " &
        "If left blank, will return the current color of the device. " &
        "If `color` is \"rand\" or \"random\" a random color will be displayed on the device",
      "device": $DeviceHelp
    }
  ],
  [
    color_tem,
    cmdName="color-tem",
    help={
      "temperature": "The color temperature you want to set on the device. " &
        "Has to be in the valid range your Govee device supports.",
      "device": $DeviceHelp
    }
  ],
  [
    state,
    help={"device": $DeviceHelp}
  ],
  [
    device,
    help={"device": $DeviceHelp}
  ],
  [
    rgb,
    help={
      "device": $DeviceHelp,
      "rgb": "The color you want to set on the device in an RGB format. " &
        "Has to be 3 numbers seperated by a space. " &
        "If left blank, the command will print the current color in an RGB function."
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
