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
      macoption = "nohidden"

    discard execShellCmd(fmt"chflags {macoption} {file}")        

proc applyPermissions*(file: string) =
  inclFilePermissions(file, {fpUserWrite, fpUserRead, fpOthersWrite, fpOthersRead})

proc setup* =
  ## Setup Nova
  
  echo "See https://neroist.github.io/nova/api-key.html if you dont't have your Govee API key\n"

  let apiKey = termuiAsk "Enter your Govee API key:"

  # lets take this opportunity to cache the list of the devices 
  let
    response = get(DevicesURI, @{"Govee-API-Key": apiKey})
    code = response.code

  if code == 200:
    # we "un-hide" the .KEY and .DEVICES files in case they exist already
    for file in [keyFile, devicesFile]:
      if file.fileExists():
        editFileVisibility(file, hidden=false)

    # write api key
    writeFile(keyFile, apiKey) 

    # cache devices
    writeFile(devicesFile, $parseJson(response.body)["data"]["devices"]) 

    # "re-hide" them
    for file in [keyFile, devicesFile]:
      editFileVisibility(file, hidden=true)

    # success!
    success "\nSetup completed successfully.\nWelcome to Nova."

    return
  else:
    # .. or not :(
    error "\nCode: ", $code
    error getErrorMsg(code)

    return
