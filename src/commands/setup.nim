import std/strformat
import std/terminal
import std/json
import std/os

import termui
import puppy

import ../common

proc editFileVisibility*(file: string; hidden: bool) =
  ## Edit file visibility of the file `file`. 
  ## 
  ## Only operates on Windows and MacOS, is simply a noop on Linux.

  when defined(windows):
    var winoption = "+h"

    if not hidden:
      winoption = "-h"

    discard execShellCmd(fmt"attrib {winoption} {file}") # add "hidden" attribute to file
  elif defined(macos) or defined(macosx):
    var macoption = "hidden"

    if not hidden:
      winoption = "nohidden"

    discard execShellCmd(fmt"chflags {macoption} {file}")        

proc applyPermissions*(file: string) =
  inclFilePermissions(file, {fpUserWrite, fpUserRead, fpOthersWrite, fpOthersRead})

proc setup* =
  ## Setup Nova
  
  echo "See https://github.com/neroist/nova#how-to-get-govee-api-key if you dont't have your Govee API key\n"

  let apiKey = termuiAsk "Enter your Govee API key:"

  # lets take this opportunity to cache the list of the devices 
  let
    response = get(DevicesURI, @{"Govee-API-Key": apiKey})
    code = response.code

  if code == 200:
    # we "un-hide" the the .KEY file incase it exists already
    # we cant write to a hidden file, apparently
    if fileExists keyFile:
      editFileVisibility(keyFile, hidden=false)

    # same for .DEVICES
    if fileExists devicesFile:
      editFileVisibility(devicesFile, hidden=false)

    writeFile(keyFile, apiKey) # write api key
    writeFile(devicesFile, $parseJson(response.body)["data"]["devices"]) # cache devices

    for file in [keyFile, devicesFile]:
      editFileVisibility(file, hidden=true)

    success "\nSetup completed successfully.\nWelcome to Nova."
    return
  else:
    error "\nCode: ", $code
    error getErrorMsg(code)
    return
