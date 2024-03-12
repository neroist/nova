# Package

version       = "1.8.0"
author        = "Jasmine"
description   = "Nova is a CLI for controlling Govee light strips, inspired by Jack Devey's Lux."
license       = "MIT"
srcDir        = "src"
bin           = @["nova"]


# Tasks

task installer, "Build Windows installer for Nova":
  selfExec"c src/nova.nim"
  exec"iscc installer/installer.iss"

task docs, "Build Nova documentation":
  withDir "docs":
    selfExec"r -d:danger -d:release book init"
    selfExec"r -d:danger -d:release book build"

task compil, "Build Nova":
  selfExec"c src/nova"

after compil:
  when defined(windows):
    exec"iscc installer/installer.iss"

# Dependencies
requires "https://github.com/neroist/nim-termui@#head"

requires "nim >= 1.6.8"
requires "tinydialogs >= 1.0.0"
requires "cligen >= 1.0.0"
requires "puppy >= 2.0.0"
requires "yanyl >= 1.1.0"
