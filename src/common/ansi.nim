import std/strformat
import std/terminal
import std/colors

proc colorToAnsi*(color: Color; foreground: bool = true): string =
  if not isTrueColorSupported():
    return ""

  result.add '\e'

  let
    rgb = color.extractRGB
    r = rgb.r
    g = rgb.g
    b = rgb.b
    start = if foreground: 38 else: 48

  result.add fmt"[{start};2;{r};{g};{b}m"

proc colorToAnsi*(color: tuple[r, g, b: range[0..255]]; foreground: bool = true): string = 
  colorToAnsi(rgb(color.r, color.g, color.b), foreground)
