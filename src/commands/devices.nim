import std/strutils
import std/terminal
import std/sugar
import std/json

import ../common

proc devices* =
  ## Get list of devices and their properties

  if not isSetup(true): return

  let devices = parseJson readFile(devicesFile) 

  for dev, i in devices.getElems():
    let 
      cmds = collect(for i in i["supportCmds"]: i.getStr())
        ## seq of all supported commands of the device

    echo "\e[1m", "DEVICE ", $dev, ansiResetCode
    echo "  Mac Address: ", i["device"].getStr()
    echo "  Model: ", i["model"].getStr()
    echo "  Device Name: ", i["deviceName"].getStr()
    echo "  Controllable: ", capitalizeAscii($i["controllable"].getBool())
    echo "  Retrievable: ", capitalizeAscii($i["retrievable"].getBool())
    echo "  Supported Commands: ", cmds.join(", "), "\n"
