##[
  Nova, a program to control Govee light strips from the command line
  Copyright (C) 2024 neroist

  This software is released under the MIT License.
  https://opensource.org/licenses/MIT
]##

import std/terminal
import std/random
import std/json

import termui/ansi
import cligen

import commands/[
  brightness,
  color_temp,
  devices,
  picker,
  update,
  setup,
  state,
  color,
  misc,
  turn,
  rgb
]

import ./common

# initialize the default random number generator
# becuase some commands need to generate random values
randomize()

# enable true color, needed so commands can look pretty!
enableTrueColors()

# also enable ansi on windows terminal
#? do we need this
enableAnsiOnWindowsConsole()

# set numDevices
if isSetup(false):
  numDevices = parseFile(devicesFile).len

# set cfg version for `nova --version`
clCfg.version = "Nova " & Version

dispatchMulti(
  [setup.setup],
  [
    turn.turn,
    help = {
      "state": "The state you want to put the device in. Has to be the string \"on\" or \"off.\" " &
                "If left blank, the command will print the current power state of the device.",
      "toggle": "Whether or not to toggle the power state of the device (if its on turn it off and " &
                "vice-versa). This flag takes precedence over the `state` option.",
      "device": $DeviceHelp,
      "output": $OutputHelp,
      "all": $AllHelp
    },
    noAutoEcho = true
  ],
  [
    brightness.brightness,
    help = {
      "brightness": "The brightness you want to set on the device. Supports values 1-100 only. " &
                    "If left blank, the command will print the current brightness of the device.",
      "device": $DeviceHelp,
      "output": $OutputHelp,
      "all": $AllHelp
    },
    noAutoEcho = true
  ],
  [
    brightness.brightness,
    cmdName = "b",
    doc = "Alias for 'brighness' command",
    noAutoEcho = true
  ],
  [
    color.color,
    help = {
      "color": "The color that you want to display on the device. " &
        "Has to be a hex/HTML color code, optionally prefixed with '#', or the string \"rand\" or \"random.\" " &
        "If left blank, will return the current color of the device. " &
        "If `color` is \"rand\" or \"random\" a random color will be displayed on the device",
      "device": $DeviceHelp,
      "output": $OutputHelp,
      "all": $AllHelp
    },
    noAutoEcho = true
  ],
  [
    color_temp.colorTemp,
    cmdName = "color-temp",
    help = {
      "temperature": "The color temperature you want to set on the device. " &
                      "Has to be in the valid range your Govee device supports.",
      "device": $DeviceHelp,
      "output": $OutputHelp,
      "all": $AllHelp
    },
    noAutoEcho = true
  ],
  [
    state.state,
    help = {
      "device": $DeviceHelp,
      "all": $AllHelp
    }
  ],
  [
    state.state,
    cmdName = "device",
    doc = "Alias for 'state' command",
    help = {
      "device": $DeviceHelp,
      "all": $AllHelp
    }
  ],
  [
    rgb.rgb,
    help = {
      "device": $DeviceHelp,
      "rgb": "The color you want to set on the device in an RGB format. " &
              "Has to be 3 numbers seperated by a space. " &
              "If left blank, the command will print the current color in an RGB function.",
      "output": $OutputHelp,
      "all": $AllHelp
    },
    noAutoEcho = true
  ],
  [
    picker.picker,
    help = {
      "device": $DeviceHelp,
      "output": $OutputHelp,
      "set_property": "Whether or not to set `device`'s color to the color chosen.",
      "all": $AllHelp
    }
  ],
  [
    update.update,
    help = {
      "output": $OutputHelp
    }
  ],
  [devices.devices],
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
