## Picker

Pick a color through a GUI and set it to `device`'s color.

### Options

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

<`-o`, `--output`> `output` - **Type: boolean (true/false/on/off). Optional.**
Whether or not the command will produce output. This also silences errors and will allow the command to fail silently.

<`-p`, `--property_set`> `property` - **Type: string/text. Optional.**
Whether or not to set `device`'s color upon picking a color. If this is
`false`, the color chosen will just be printed to the terminal. Defaults
to `true`

### Usage

```sh
nova picker --device:[device] --output:[true|false] --property_set:[true|false]
```

### Examples

```sh
nova picker -p:false
nova picker -d:1 -o:false
```
