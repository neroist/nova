## This module contains helper functions so Nova can run properly

#[
  Nova, a program to control Govee light strips from the command line
  Copyright (C) 2024 neroist

  This software is released under the MIT License.
  https://opensource.org/licenses/MIT
]#

import std/strformat
import std/terminal
import std/json
import std/os

# import yanyl

import common/messages
import common/ansi
import common/api

include common/vars

proc checkDevices*(device: int; devices: int = numDevices; output: bool = on): bool =
  result = true
  
  if device notin 0..<devices:
    if output:
      error fmt"Invalid device '{device}'. You have {devices} device(s)."

    return false

proc isSetup*(output: bool = on; keyDir = keyFile, devicesDir = devicesFile, errmsg = NotSetupErrorMsg): bool =
  ## Checks if Nova is setup properly

  # nested so we don't read from a file that doesnt exist
  if fileExists(keyDir) and fileExists(devicesDir): 
    if "" notin [readFile(keyDir), readFile(devicesDir)]:
      return true
  else:
    if output:
      error errmsg

    return false

# set numDevices
if isSetup(false):
  numDevices = parseFile(devicesFile).len

export api
export ansi
export messages
