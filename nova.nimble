# Package

version       = "1.7.0"
author        = "Jasmine"
description   = "Nova is a CLI for controlling Govee light strips, inspired by Jack Devey's Lux."
license       = "MIT"
srcDir        = "src"
bin           = @["nova"]


# Tasks

task installer, "Build installer for Nova":
  when defined(windows):
    exec "iscc installer/installer.iss"
  else:
    cpFile "installer/install.sh", "bin/install.sh"

task docs, "Build Nova documentation":
  withDir "docs":
    selfExec "r book init"
    selfExec "r book build"

task nova, "Build Nova":
  selfExec "c -f src/nova"

# Dependencies
requires "https://github.com/neroist/nim-termui#head"

requires "nim >= 1.6.8"
requires "tinydialogs >= 1.0.0"
requires "cligen >= 1.0.0"
requires "puppy >= 2.0.0"
requires "yanyl >= 1.1.0"
