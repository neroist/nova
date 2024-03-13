import std/strformat
import std/terminal
import std/json
import std/os

import termui
import puppy

import ../common

proc editFileVisibility*(file: string; hidden: bool) =
  ## Edit file visibility of the file `file`. Only edits for Windows and
  ## MacOS, as you can hide a file in linux by simply adding a period before
  ## the file name (and show a file by removing the period).

  var
    winoption = "+h"
    macoption = "hidden"

  if defined(windows) and (not hidden):
    winoption = "-h"
  elif (defined(macos) or defined(macosx)) and (not hidden):
    macoption = "nohidden"

  when defined(windows):
    discard execShellCmd(fmt"attrib {winoption} {file}") # add "hidden" attribute to file
  elif defined(macos) or defined(macosx):
    discard execShellCmd(fmt"chflags {macoption} {file}") # set "hidden" flag on file

proc setup* =
  ## Setup Nova
  
  echo "See https://github.com/neroist/nova#how-to-get-govee-api-key if you dont't have your Govee API key\n"

  let apiKey = termuiAsk "Enter your Govee API key:"

  # lets take this opportunity to cache the list of the devices 
  let
    response = get(DevicesURI, @{"Govee-API-Key": apiKey})
    code = response.code

  if code == 200:
    # we "un-hide" the the .KEY file incase it exists already because
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
