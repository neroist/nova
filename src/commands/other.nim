## other, kinda-related commands that don't do much

import std/browsers

import puppy

import ../common

proc version* =
  ## Get Nova current version

  echo "Nova ", Version

proc about* =
  ## Nova about

  echo "Nova ", Version, '\n'
  echo Description
  echo "Made by ", Author, '.'

proc description* =
  ## Prints Nova's description

  echo Description

proc source* =
  ## View Nova's source code

  openDefaultBrowser("https://github.com/neroist/nova/blob/main/src/nova.nim")

proc repo* =
  ## View Nova's GitHub repository

  openDefaultBrowser("https://github.com/neroist/nova/")

proc license*(browser: bool = false) =
  ## View Nova's license
  
  if browser:
    openDefaultBrowser("https://github.com/neroist/nova/blob/main/LICENSE")
  else:
    echo fetch("https://raw.githubusercontent.com/neroist/nova/main/LICENSE")

proc docs* =
  ## View Nova's documentation

  openDefaultBrowser("https://neroist.github.io/nova/")
