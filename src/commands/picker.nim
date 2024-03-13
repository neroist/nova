import std/strutils
import std/random
import std/colors

import tinydialogs

import ../common
import ./color

proc picker*(device: int = 0; setProperty: bool = true; output: bool = on) = 
  ## Pick a color through a GUI (your OS's default color picker dialog)

  let 
    pickedColor = colorChooser(
      "Pick a color", 
      [rand(0..255).byte, rand(0..255).byte, rand(0..255).byte]
    )

  if output:
    echo "Picked ", colorToAnsi(parseColor(pickedColor.hex)), toUpper pickedColor.hex, esc

  if setProperty:
    if output: echo ""

    discard color(device, pickedColor.hex, output)

