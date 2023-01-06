# Nova
Nova is a CLI for controlling Govee light strips. Inspired by Bandev's [Lux](https://github.com/BanDev/Lux).
Made with Nim.

Not affiliated with Govee.

## Contents
(Tip: Click on the 3 lines on the file header to access the automatically generated table of contents.)
- [Supported Devices](#supported-devices)
- [Notes](#important-notes)
- [Installation](#installation)
- [Deletion](#deletion)
- [Documentation](#documentation)

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
**Positional arguments are not supported.** For example: `nova color 0 "aliceblue"` will not work and throw an error. You will have to explicitly declare every argument you pass into the command. For example: `nova color -d 0 -c "aliceblue"`. Also, see [`setup`](DOCS.md#setup).

## Installation
If you have Windows you can just download the installer from the [most recent version](https://github.com/nonimportant/nova/releases/latest).
Else, follow these steps:

1. Download your OS's execuable from the [most recent version](https://github.com/nonimportant/nova/releases/latest) (If your browser or antivirus raises a warning, ignore it and let it bypass. If you don't, there might be problems with step 4 and 5).
2. Rename the file name to `nova`.
3. Create a directory in your root or home directory, then move the file into that directory (the location doesn't actually matter just don't leave it in the Downloads folder. I suggest this directory only have the file in it and nothing else because of the next step).
4. Add the directory to your `Path` environment variable, or else you'll have to go to and find the directory and open a terminal in that directory just to use Nova.
5. Run `nova setup` in your terminal/shell, and you're good to go (see [`setup`](https://github.com/nonimportant/nova/blob/main/README.md#setup)'s docs if there are any problems).

## Deletion
1. Delete Nova from whatever directory you put it in (or delete the directory itself).

Or, if you installed with the installer, open Settings, go to Apps, then search for "Nova." When you see Nova, click the three dots and hit "Uninstall."

## Documentation
See [DOCS.md](DOCS.md)

## Build from source
### Reqirements
- [Nim](https://nim-lang.org) >= 1.6.8
- Mingw installed from [MSYS2](https://www.msys2.org) MSYS (only needed if you want to build windows installer)
- [Inno Setup](https://jrsoftware.org/isdl.php#stable) (again, only needed for windows installer)

### Build
In order to build, cd into the base directory and run:

```shell
nimble tinydialogs cligen puppy
nim c src/nova.nim

iscc installer/installer.iss # skip if you dont want to build installer
```

The compilied binaries will be avalible in the `bin/` directory.

###### Made with ❤️ with Nim
