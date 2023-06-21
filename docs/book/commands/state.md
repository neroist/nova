## State

`state` is a command for retriving the state of a Govee device.

Alias: `device`

```text
Usage:
  state [optional-params] 

Options:
  -h, --help                   print this cligen-erated help
  --help-syntax                advanced: prepend,plurals,..
  --version       bool  false  print version
  -d=, --device=  int   0      The device to perform the action/command on. Defaults to '0'. '0' refers to the first device on your account, '1' refers to the second, ect. See the full list  
                               of devices with `nova devices`.
```

### Options

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

### Usage

```sh
nova state -d:[device]
```

### Examples

```sh
nova state
nova state -d:5
```
