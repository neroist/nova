## Brightness

`brightness` is a command for controlling or retrieving a Govee light strip's brightness.

```text
Usage:
  brightness [optional-params]

Options:
  -h, --help                       print this cligen-erated help
  --help-syntax                    advanced: prepend,plurals,..
  --version           bool  false  print version
  -d=, --device=      int   0      The device to perform the action/command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect. See the full   
                                   list of devices with `nova devices`.
  -b=, --brightness=  int   -1     The brightness you want to set on the device. Supports values 1-100 only. If left blank, the command will print the current brightness of the device.       
  -o, --output        bool  true   Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.
```

### Options

<`-b`, `--brightness`> `brightness` - **Type: int/integer. Optional.**
The brightness you want to set on the device. Supports values 1-100 only.
If left blank, the command will print the current brightness of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect.

<`-o`, `--output`> `output` - **Type: bool (true/false/on/off). Optional.**
Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.

### Usage

```sh
nova brightness --device:[device] -brightness:[brightness]
```

### Examples

```sh
nova brightness --brightness:100
nova brightness 
nova brightness -b:70 -d:2
```
