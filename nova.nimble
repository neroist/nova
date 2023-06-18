# Package

version       = "1.6.2"
author        = "Jasmine"
description   = "Nova is a CLI for controlling Govee light strips, inspired by Bandev's Lux."
license       = "MIT"
srcDir        = "src"
bin           = @["nova"]


# Tasks

task installer, "Build Windows installer for Nova":
  selfExec"c src/nova.nim"
  exec"iscc installer/installer.iss"


# Dependencies

requires "nim >= 1.6.8"
requires "tinydialogs ~= 1.0.0"
requires "cligen >= 1.0.0"
requires "termui >= 0.1.0"
requires "puppy >= 2.0.0"
