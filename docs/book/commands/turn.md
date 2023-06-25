## Turn

`turn` is a command for turning a Govee device on or off.

```text
Usage:
  turn [optional-params] 

Options:
  -h, --help                     print this cligen-erated help
  --help-syntax                  advanced: prepend,plurals,..
  --version       bool    false  print version
  -d=, --device=  int     0      The device to perform the action/command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect.
  -s=, --state=   string  ""     The state you want to put the device in. Has to be the string "on" or "off." If left blank, the command will print the current power state of the device.
  -t, --toggle    bool    false  Whether or not to toggle the power state of the device (if its on turn it off and vice-versa). This flag takes precedence over the `state` option.
  -o, --output    bool    true   Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.
```

### Options

<`-s`, `--state`> `state` - **Type: str/string. Optional.**
The state you want to put the device in.
Has to be the string "on" or "off." If left blank, the command will print the current power state of the device.

<`-t`, `--toggle`> `toggle` - **Type: bool (true/false/on/off). Optional.**
Whether or not to toggle the power state of the device (if its on turn it off and vice-versa). This flag takes precedence over the `state` option

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

<`-o`, `--output`> `output` - **Type: bool (true/false/on/off). Optional.**
Whether or not the command will produce output. This also silences errors and will allow the command fail silently.

### Usage

```sh
nova turn --device:[device] --state:[state]
```

### Examples

```sh
nova turn --status:on
nova turn -d:2 -s:"off"
nova turn 
```
