import std/colors
import std/json

type
  GoveeDevice* = ref object
    ## object that represents a govee device, as provided by `/v1/devices`

    device*: string
    model*: string
    deviceName*: string
    controllable*: bool
    retrievable*: bool
    supportCmds*: seq[string]
    properties*: JsonNode

  DeviceState* = object
    ## object that represents a device *state*, as provided by `/v1/devices/state`

    properties*: JsonNode
      ## dummy attribute used to later populate the other fields

    device*: string
    model*: string
    online*: bool
    powerState*: bool
    brightness*: int
    color*: Color
    colorTemp*: int

proc hasTemp*(dev: GoveeDevice): bool =
  ## Returns whether or not the device contains a color temperature

  dev.properties.contains("colorTem")

proc tempRange*(dev: GoveeDevice): Slice[int] =
  ## Returns the device's color temperature range

  # exit if no color temp
  if dev.hasTemp() == false:
    return

  # minimum value; lower bound
  result.a = dev.properties["colorTem"]["range"]["min"].getInt()

  # maximum value; upper bound
  result.b = dev.properties["colorTem"]["range"]["max"].getInt()

# proc renameHook*(dev: var GoveeDevice, fieldName: var string) =
#   if fieldName == "supportCmds":
#     fieldName = "supportedCmds"

# ---

proc getColor(color: JsonNode): Color =
  ## Parses a color from a JSON object of this structure:
  ## 
  ## ```
  ## "color": {
  ##  "r": ...,
  ##  "b": ...,
  ##  "g": ...
  ## }
  ## ```
  ## 
  ## ... as found in the Govee API

  rgb(
    color["r"].getInt(),
    color["g"].getInt(),
    color["b"].getInt()
  )

proc hasColor*(dev: DeviceState): bool =
  ## returns whether or not the specified device has the `color` attribtute set
  
  # whenever the `color` attr is not set, `colorTemp` is not zero
  dev.colorTemp != 0

proc postHook*(dev: var DeviceState) =
  ## populates `dev`'s fields from `dev.properties`, ran as a post hook with jsony

  # properties.online contains a string instead of a bool...
  # compares the string to "true" in order to deduce the needed bool value
  dev.online = (dev.properties[0]["online"].getStr() == "true")

  # similar situation here, except the value is either "on" or "off"
  dev.powerState = (dev.properties[1]["powerState"].getStr() == "on")

  dev.brightness = dev.properties[2]["brightness"].getInt()

  # the returned json in `dev.properties` may not provide a `color` field, instead
  # replacing it with a `colorTemInKelvin` when the color temperature is set on a device
  if dev.properties[3].contains("color"):
    dev.color = dev.properties[3]["color"].getColor()
  else:
    dev.colorTemp = dev.properties[3]["colorTemInKelvin"].getInt()
  