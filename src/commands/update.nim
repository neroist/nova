import std/json

import puppy

import ../common
import ./setup

proc update*(output: bool = on) = 
  ## Update the cached list of devices. Run whenever a new device is added
  ## or modified.
  
  let
    apiKey = readFile(keyFile) 
    response = fetch(DevicesURI, @{"Govee-API-Key": apiKey})
  
  editFileVisibility(devicesFile, false)

  writeFile(devicesFile, $parseJson(response)["data"]["devices"])

  editFileVisibility(devicesFile, true)

  if output:
    success "Successfully updated devices!"
