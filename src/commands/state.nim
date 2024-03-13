import std/strformat
import std/strutils
import std/terminal
import std/colors
import std/json

import ./color_temp
import ../common

proc state*(device: int = 0) =
  ## Output state of device

  if not isSetup(true) or not checkDevices(device, output=true): return

  var
    colorJson = %* {"r": 0, "g": 0, "b": 0}
    colorTem = 0 

  let
    apiKey = readFile(keyFile)
    devices = parseJson readFile(devicesFile)
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
