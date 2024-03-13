import std/strformat
import std/json
import std/uri

import puppy

func getDeviceInfo*(jsonData: JsonNode; device: int): tuple[deviceAddr, model: string] =
  let
    deviceAddr = jsonData[device]["device"].getStr()
    model = jsonData[device]["model"].getStr()

  result = (deviceAddr: deviceAddr, model: model)

proc getDeviceState*(deviceAddr, model, apiKey: string): JsonNode = 
  parseJson(
    fetch(
      &"https://developer-api.govee.com/v1/devices/state?device={encodeUrl(deviceAddr, false)}&model={model}",
      @{"Govee-API-Key": apiKey}
    )
  )
