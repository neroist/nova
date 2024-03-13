# included by ../common.nim

const
  DeviceHelp* = "The device to perform the action/command on. Defaults to '0'. " &
    "'0' refers to the first device on your account, '1' refers to the second, ect. " &
    "See the full list of devices with `nova devices`."
    ## "Device" option help text.
  
  OutputHelp* = "Whether or not the command will produce output."
    ## "Output" option help text.
  
  AllHelp* = "If enabled, the command will run on all devices. Ignores `device` option."
    ## "All" option help text.
  
  NotSetupErrorMsg* = "Nova is not setup properly. Use the command `nova setup` to setup Nova."
    ## Error message when Nova is not setup properly.
  
  Version* = "v1.7.0"
    ## Nova version
  
  Description* = "Nova is a CLI for controlling Govee light strips, inspired by Jack Devey's Lux."
    ## Nova description
  
  DevicesURI* = "https://developer-api.govee.com/v1/devices"
    ## The base URI used to get device information.
  
  ControlURI* = DevicesURI & "/control"
    ## The base URI used to control devices.
  
  Author* = "Jasmine"
    ## The creator of Nova (me! :3)

var
  numDevices*: int

let
  esc* = if isTrueColorSupported(): ansiResetCode
         else: ""

  keyFile* = getAppDir() / ".KEY"
  savesFile* = getAppDir() / ".saves.yaml"
  devicesFile* = getAppDir() / ".DEVICES"
