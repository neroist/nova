import std/strutils

import jsony

import ../common

proc devices* =
  ## Get list of devices and their properties

  if not isSetup(true): return

  let devices = readFile(devicesFile).fromJson(seq[GoveeDevice])

  for idx, device in devices:
    echo bold, "DEVICE ", idx, esc

    echo "\tMac Address: ", device.device
    echo "\tModel: ", device.model
    echo "\tDevice Name: ", device.deviceName
    echo "\tControllable: ", device.controllable
    echo "\tRetrievable: ", device.retrievable
    echo "\tSupported Commands: ", device.supportCmds.join(", "), "\n"
