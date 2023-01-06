# Package

version       = "1.6.1"
author        = "Jasmine"
description   = "Nova is a CLI for controlling Govee light strips, inspired by Bandev's Lux."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["nova"]


# Dependencies

requires "nim >= 1.6.8"
requires "tinydialogs"
requires "cligen"
requires "termui"
requires "puppy"
