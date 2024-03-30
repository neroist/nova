import std/strformat
import std/strutils
import std/terminal
import std/colors

import ./color_temp
import ../common

proc state*(device: int = 0; all: bool = false) =
  ## Output state of device

  if not isSetup(true) or not checkDevices(device, output=true): return

  if all:
    for i in 0..<numDevices-1:
      state(i)

  let
    govee_device = getDevice(device)
    state = getDeviceState(govee_device.device, govee_device.model)

  let
    device_color = state.color
    (r, g, b) = state.color.extractRGB()

    ansi_color = colorToAnsi state.color
    ansi_color_temp = colorToAnsi(kelvinToRgb(state.colorTemp))

  styledEcho styleItalic, "DEVICE ", $device, ansiResetCode
  echo &"\tMac Address: {state.device}"
  echo &"\tModel: {state.model}"
  echo &"\tOnline: {state.online} (may be incorrect)"
  echo &"\tPower State: {state.powerState}"
  echo &"\tBrightness: {state.brightness}"
  echo &"\tColor: {ansi_color}{device_color}{esc} or {ansi_color}rgb({r}, {g}, {b}){esc}"
  echo &"\tColor Temperature: {ansi_color_temp}{state.colorTemp}K{esc} (if not 0K, color will be #000000)"
