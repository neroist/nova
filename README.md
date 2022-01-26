# Nova
Nova is a CLI for controlling Govee light strips inspired by [Bandev's Lux](https://github.com/BanDev/Lux).
Made in Nim.

Not affiliated with Govee or Bandev.

## Contents
- [Supported Devices](https://github.com/nonimportant/nova/blob/main/README.md#supported-devices)
- [Notes](https://github.com/nonimportant/nova/blob/main/README.md#important-notes)
- [Installation](https://github.com/nonimportant/nova/blob/main/README.md#installation)
- [Deletion](https://github.com/nonimportant/nova/blob/main/README.md#deletion)
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
    - [Rgb](https://github.com/nonimportant/nova/blob/main/README.md#rgb)
        - [Options](https://github.com/nonimportant/nova/blob/main/README.md#options-5)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-6)
        - [Examples](https://github.com/nonimportant/nova/blob/main/README.md#examples-5)
    - [Devices](https://github.com/nonimportant/nova/blob/main/README.md#devices)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-7)
    - [Version](https://github.com/nonimportant/nova/blob/main/README.md#version)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-8)
    - [About](https://github.com/nonimportant/nova/blob/main/README.md#about)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-9)
    - [Description](https://github.com/nonimportant/nova/blob/main/README.md#description)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-10)
    - [Source](https://github.com/nonimportant/nova/blob/main/README.md#source)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-11)
    - [Repo](https://github.com/nonimportant/nova/blob/main/README.md#repo)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-12)
    - [License](https://github.com/nonimportant/nova/blob/main/README.md#license)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-13)
    - [Docs](https://github.com/nonimportant/nova/blob/main/README.md#docs)
        - [Usage](https://github.com/nonimportant/nova/blob/main/README.md#usage-14)


## Supported Devices
Not all Govee devices are supported by Nova. The devices supported by Nova are:
H6160, H6163, H6104, H6109, H6110, H6117, H6159, H7022, H6086,
H6089, H6182, H6085, H7014, H5081, H6188, H6135, H6137, H6141,
H6142, H6195, H7005, H6083, H6002, H6003, H6148, H6052, H6143,
H6144, H6050, H6199, H6054, H5001, H6050, H6154, H6143, H6144,
H6072, H6121, H611A, H5080, H6062, H614C, H615A, H615B, H7020,
H7021, H614D, H611Z, H611B, H611C, H615C, H615D, H7006, H7007,
H7008, H7012, H7013, H7050, H6051, H6056, H6061, H6058, H6073,
H6076, H619A, H619C, H618A, H618C, H6008, H6071, H6075, H614A,
H614B, H614E, H618E, H619E, H605B, H6087, H6172, H619B, H619D,
H619Z, H61A0, H7060, H610A, H6059, H7028, H6198, H6049.

Only Wi-Fi devices are supported.

## Important Notes
**Positional arguments are not supported.** For example: `nova color 0 "aliceblue"` will not work and throw an error. You will have to explicitly declare every argument you pass into the command. For example: `nova color -d 0 -c "aliceblue"`. Also, see [`setup`](https://github.com/nonimportant/nova/blob/main/README.md#setup).

## Installation
1. Download the .exe from the [most recent version](https://github.com/nonimportant/nova/releases/latest) (If your browser or antivirus raises a warning, ignore it and let it bypass. If you don't, there might be problems with step 4).
2. Create a directory in your root or home directory, then move the file into that directory (the location doesn't actually matter just don't leave it in the Downloads folder. I suggest this directory only have the file in and nothing else because of the next step).
3. Add the directory to your `Path` environment variable, or else you'll have to go to and find the directory and open a terminal in that directory just to use Nova.
4. Run `nova setup` in your terminal/shell, and you're good to go (see [`setup`](https://github.com/nonimportant/nova/blob/main/README.md#setup)'s docs if there are any problems).

## Deletion
1. Delete nova.exe from whatever directory you put it in.
###### Thats it!

## Commands:

## Setup
`setup` is a command for setting up Nova. Nova is reqired to be setup for Nova to work. 
###### **Note: you *may* need to give your shell root/administrator permissions for this command to work.**
###### If this command still doesn't work, make a file called ".KEY" in the same directory that nova.exe is in and put your Govee API key in it.

### Usage
```
nova setup
```

## Turn
`turn` is a command for turning a Govee device on or off.
### Options
<`-s`, `--state`> `state` - **Type: str/string. Optional.**
The state you want to put the device in.
Has to be the string "on" or "off." If left blank, the command will print the current power state of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.
### Usage
```
nova turn --device:[device] --state:[state]
```
### Examples
```
nova turn --status:on
nova turn -d:2 -s:"off"
nova turn 
```

## Brightness
`brightness` is a command for controlling and retrieving a Govee light strip's brightness.
### Options
<`-b`, `--brightness`> `brightness` - **Type: int/integer. Optional.**
The brightness you want to set on the device. Supports values 1-100 only.
If left blank, the command will print the current brightness of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.
### Usage
```
nova brightness --device:[device] -brightness:[brightness]
```
### Examples
```
nova brightness --brightness:100
nova brightness 
nova brightness -b:1 -d:3
```
## Color
`color` is a command for controlling and retrieving a Govee light strip's color.
With this command you can also change a Govee device's color to a random one.

**NOTE**: When called with no parameters, the device's current color will be #000000 if:
1. Music mode is on.
2. Color temperature is not 0. or
3. A scene is playing on the device.

### Options
<`-c`, `--color`> `color` - **Type: str/string. Optional.**
The color you want to set on the device. Has to be an HTML/hex color code (a "#" is optional), a color name [(click here to see a list of color names)](https://www.w3schools.com/colors/colors_hex.asp), or the string "rand" or "random."
If the string "rand" or "random" is passed, a random color will be chosen. If left blank, the command will print the current color of the device.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

### Usage
```
nova color --device:[device] --color:[color or "rand"|"random"]
```

### Examples
```
nova color -c "#6A0748"
nova color -d:1 -c:random
nova color -c "alice blue" 
nova color -d=2
nova color 
```

## Color-tem
`color-tem` is a command for controlling the color temperature of a Govee light strip.

### Options
<`-t`, `--temperature`> `temperature` - **Type: int/integer. Reqired.**
The color temperature you want to set on the device. Has to be in the valid range your Govee device supports.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

### Usage
```
nova color-tem --device:[device] --temperature:[temperature]
```

### Examples
```
nova color-tem -t:5000
nova color-tem -d:2 -t:4675
```

## State
`state` is a command for retriving the state of a Govee device.

Alias: `device`

### Options
<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

### Usage
```
nova state -d:[device]
```

### Examples
```
nova state
nova state -d:5
```

## Rgb
`rgb` is a command for controlling and retrieving a Govee light strip's color.
With this command you can also change a Govee device's color to a random one.

**NOTE**: When called with no parameters, the device's current color will be rgb(0, 0, 0) if:
1. Music mode is on.
2. Color temperature is not 0. or
3. A scene is playing on the device.

### Options
`rgb` - **Type: list/sequence. Optional.**
The color you want to set on the device. Has to be 3 numbers seperated by a space.
This option has no `-x` or `--x` ~~thing~~, a list of numbers/integers are just given to the command.
If left blank, the command will print the current color in an rgb function.

<`-d`, `--device`> `device` - **Type: int/integer. Optional.**
The device to perform the command on. Defaults to '0.' '0' refers to the first device on your account, '1' refers to the second, ect.

### Usage
```
nova rgb r g b --device:[device]
```

### Examples
```
nova rgb 12 181 192 -d:3
nova rgb -d:2
nova rgb 217 140 180
```

## Devices
`devices` is a command for getting the list of Govee devices on your account.

### Usage
```
nova devices
```

## Version
`version` is a command for getting Nova's current version.

### Usage
```
nova version
```

## About
`about` is a command for getting Nova's about (i.e. Nova's version and description).

### Usage
```
nova about
```

## Description
`description` is a command for getting Nova's description

### Usage
```
nova description
```

## Source
`source` is a command for opening Nova's source code

### Usage
```
nova source
``` 

## Repo
`repo` is a command for opening Nova's GitHub repository

### Usage
```
nova repo
```

## License 
`license` is a command for getting Nova's licence

### Usage
```
nova license
```

## Docs
`docs` is a command for getting Nova's description

### Usage
```
nova docs
```

