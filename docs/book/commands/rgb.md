## RGB

`rgb` is a command for controlling or retrieving a Govee light strip's color.
Essentially the same as `color`, but accepts a color in an RGB format,
although it doesn't support random colors.

**NOTE**: When called with no parameters, the device's current color will
be rgb(0, 0, 0) if:

  1. Music mode is on.
  2. Color temperature is not 0. or
  3. A scene is playing on the device.

```text
Usage:
  rgb [optional-params] 

Options:
  -h, --help                   print this cligen-erated help
  --help-syntax                advanced: prepend,plurals,..
  --version       bool  false  print version
  -d=, --device=  int   0      The device to perform the action/command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect. See the full list  
                               of devices with `nova devices`.
  -o, --output    bool  true   Whether or not the command will produce output. This also silences errors and will let commands fail silently.
```

### Options

`rgb` - **Type: list/sequence. Optional.**
The color you want to set on the device. Has to be 3 (or less) numbers
separated by a space in the format of `r g b`. There is no `--rgb` option,
just a list of numbers/integers are just passed to the command. If left blank,
the command will print the current color in an rgb format.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

<`-o`, `--output`> `output` - **Type: boolean (true/false/on/off). Optional.**
Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.

### Usage

```sh
nova rgb r g b --device:[device]
```

### Examples

```sh
nova rgb 12 181 192 -d:3
nova rgb -d:2
nova rgb 217 140 180
```
