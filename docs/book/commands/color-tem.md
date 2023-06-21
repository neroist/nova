## Color Tem

`color-tem` is a command for controlling the color temperature of a Govee light strip.

```text
Usage:
  color-temp [optional-params]

Options:
  -h, --help                        print this cligen-erated help
  --help-syntax                     advanced: prepend,plurals,..
  --version            bool  false  print version
  -d=, --device=       int   0      The device to perform the action/command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect. See the full
                                    list of devices with `nova devices`.
  -o, --output         bool  true   Whether or not the command will produce output. This also silences errors and will let commands fail silently.
  -t=, --temperature=  int   -1     The color temperature you want to set on the device. Has to be in the valid range your Govee device supports.
```

### Options

<`-t`, `--temperature`> `temperature` - **Type: int/integer. Reqired.**
The color temperature you want to set on the device. Has to be in the valid range your Govee device supports.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect.

<`-o`, `--output`> `output` - **Type: boolean (true/false/on/off). Optional.**
Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.

### Usage

```sh
nova color-tem --device:[device] --temperature:[temperature]
```

### Examples

```sh
nova color-tem -t:5000
nova color-tem -d:2 -t:4675
```
