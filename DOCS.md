# Nova CLI docs

## Contents
- [Commands](https://github.com/nonimportant/nova/blob/main/README.md#commands)
  - [Setup](https://github.com/nonimportant/nova/blob/main/README.md#setup)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage)
  - [Turn](https://github.com/nonimportant/nova/blob/main/README.md#turn)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-1)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples)
  - [Brightness](https://github.com/nonimportant/nova/blob/main/README.md#brightness)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-1)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-2)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-1)
  - [Color](https://github.com/nonimportant/nova/blob/main/README.md#color)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-2)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-3)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-2)
  - [Color-tem](https://github.com/nonimportant/nova/blob/main/README.md#color-tem)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-3)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-4)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-3)
  - [State](https://github.com/nonimportant/nova/blob/main/README.md#state)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-4)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-5)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-4)
  - [Device](https://github.com/nonimportant/nova/blob/main/README.md#device)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-5)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-6)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-5)
  - [Rgb](https://github.com/nonimportant/nova/blob/main/README.md#rgb)
    - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-6)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-7)
    - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-6)
  - [Devices](https://github.com/nonimportant/nova/blob/main/README.md#devices)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-8)
  - [Version](https://github.com/nonimportant/nova/blob/main/README.md#version)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-9)
  - [About](https://github.com/nonimportant/nova/blob/main/README.md#about)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-10)
  - [Description](https://github.com/nonimportant/nova/blob/main/README.md#description)
    - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-11)

## Commands

### Setup
Setup is a command for setting up Nova. Nova is reqired to be setup for the commands to work.
#### Usage
```
nova setup
```
    
### Turn
`turn` is a command for turning a Govee device on or off. 
#### Options
<`-s`, `--state`> `state` - **Type: str/string. Optional.**
The state you want to put the device in. 
Has to be the string "on" or "off." If left blank, the command will print the current power state of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect. 
#### Usage
```
nova turn --device:[device] --state:[state]
```
 #### Examples
```
nova turn --status:on
nova turn -d:2 -s:"off"
nova turn 
```

### Brightness
`brightness` is a command for controlling and retrieving a Govee light strip's brightness.
#### Options
<`-b`, `--brightness`> `brightness` - **Type: int/integer. Optional.**
The brightness you want to set on the device. Supports values 1-100 only. 
If left blank, the command will print the current brightness of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect. 
#### Usage
```
nova brightness --device:[device] -brightness:[brightness]
```
#### Examples
```
nova brightness --brightness:100
nova brightness 
nova brightness -b:1 -d:3
```
### Color
`color` is a command for controlling and retrieving a Govee light strip's color. 
With this command you can also change a Govee device's color to a random one. 

**NOTE**: When called with no parameters, the device's current color will be #000000 if:
1. Music mode is on. 
2. Color temperature is not 0. or
3. A scene is playing on the device.

#### Options
<`-c`, `--color`> `color` - **Type: str/string. Optional.**
The color you want to set on the device. Has to be an HTML/hex color code, prefixing it with '#' is optional though, or the string "rand" or "random."
If the string "rand" or "random" is passed, a random color will be chosen. If left blank, the command will print the current color of the device. 

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect. 

#### Usage
```
nova color --device:[device] --color:[color or "rand"|"random"]
```

#### Examples
```
nova color -c:"#6A0748"
nova color -d:1 -c:"random"
nova color 
nova color -d:2
```

### Color-tem
`color-tem` is a command for controlling the color temperature of a Govee light strip.

#### Options
<`-t`, `--temperature`> `temperature` - **Type: int/integer. Reqired.**
The color temperature you want to set on the device. Has to be in the valid range your Govee device supports.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

#### Usage
```
nova color-tem --device:[device] --temperature:[temperature]
```

#### Examples
```
nova color-tem -t:5000
nova color-tem -d:2 -t:4675
```

### State 
`state` is a command for retriving the state of a Govee device.

#### Options
<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

#### Usage
```
nova state -d:[device]
```

#### Examples
```
nova state
nova state -d:5
```

### Device
`device` is an for `state`.

#### Options
<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

#### Usage
```
nova device -d:[device]
```

#### Examples
```
nova device
nova device -d:5
```

### Rgb
`rgb` is a command for controlling and retrieving a Govee light strip's color. 
With this command you can also change a Govee device's color to a random one. 

**NOTE**: When called with no parameters, the device's current color will be rgb(0, 0, 0) if:
1. Music mode is on. 
2. Color temperature is not 0. or
3. A scene is playing on the device.

#### Options
`rgb` - **Type: list/sequence. Optional.**
The color you want to set on the device. Has to be 3 numbers seperated by a space. 
This option has no `-x` or `--x` ~~thing~~, a list of numbers/integers are just given to the command. 
If left blank, the command will print the current color in an rgb function.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect. 

#### Usage
```
nova rgb --device:[device] r g b
```

#### Examples
```
nova rgb 12 181 192 -d:3
nova rgb -d:2
nova rgb 217 140 180
```

### Devices
`devices` is a command for getting the list of Govee devices on your account.

#### Usage
```
nova devices
```

### Version
`version` is a command for getting Nova's current version.

#### Usage
```
nova version
```

### About
`about` is a command for getting Nova's about (i.e. Nova's version and description). 

#### Usage
```
nova about
```

### Description
`description` is a command for getting Nova's description

#### Usage
```
nova description
```
