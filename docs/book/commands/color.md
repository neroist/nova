## Color

`color` is a command for controlling or retrieving a Govee light strip's color.
With this command you can also change a Govee device's color to a random one.

**NOTE**: When called with no parameters, the device's current color will be #000000 if:

  1. Music mode is on.
  2. Color temperature is not 0. or
  3. A scene is playing on the device.

```text
Usage:
  color [optional-params] 

Set device color with an HTML/hex color code.

Options:
  -h, --help                     print this cligen-erated help
  --help-syntax                  advanced: prepend,plurals,..
  --version       bool    false  print version
  -d=, --device=  int     0      The device to perform the action/command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect. See the full list
                                 of devices with `nova devices`.
  -c=, --color=   string  ""     The color that you want to display on the device. Has to be a hex/HTML color code, optionally prefixed with '#', or the string "rand" or "random." If left
                                 blank, will return the current color of the device. If `color` is "rand" or "random" a random color will be displayed on the device
  -o, --output    bool    true   Whether or not the command will produce output. This also silences errors and will let commands fail silently.
```

### Options

<`-c`, `--color`> `color` - **Type: str/string. Optional.**
The color you want to set on the device. Has to be an HTML/hex color code (a "#" is optional), a color name ([click here to see a list of color names](https://www.w3schools.com/colors/colors_hex.asp)), or the string "rand" or "random."
If the string "rand" or "random" is passed, a random color will be chosen. If left blank, the command will print the current color of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

<`-o`, `--output`> `output` - **Type: boolean (true/false/on/off). Optional.**
Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.

### Usage

```sh
nova color --device:[device] --color:[color or "rand"|"random"]
```

### Examples

```sh
nova color -c "#6A0748"
nova color -d:1 -c:random
nova color -c "alice blue" 
nova color -d=2
nova color 
```
