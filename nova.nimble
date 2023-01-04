# Package

version       = "1.6.0"
author        = "Jasmine"
description   = "Nova is a CLI for controlling Govee light strips, inspired by Bandev's Lux."
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["nova"]


# Dependencies

requires "nim >= 1.4.4"
requires "tinydialogs"
requires "cligen"
requires "termui"
