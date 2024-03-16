#!/bin/bash

# set -e

# check if sudo
if [ "$(id -u)" -ne 0 ]; then
  printf "Please run as root/sudo!\n"
  exit 1
fi

# vars
novaver="1.7.0"
novadir="/usr/local/nova"
bit=""
dir=""

read -p "What directory should Nova install to? (defaults to $novadir) " input
read -p "Do you want to install the 32 bit version (leave blank for no, 'both' for both) " bit32

if [ -n "$dir" ]; then
  novadir=$dir
fi

printf "\nInstalling to $novadir/\n"

mkdir -p $novadir

if [[ -n "$bit" ]]; then
  wget -q -O "$novadir/nova" "https://github.com/neroist/nova/releases/download/$novaver/nova32"
  
  if [[ "$bit" == "both" ]]; then
    wget -q -O "$novadir/nova" "https://github.com/neroist/nova/releases/download/$novaver/nova"
  fi
else
  wget -q -O "$novadir/nova" "https://github.com/neroist/nova/releases/download/$novaver/nova"
fi

## make symlink to nova in secure path
[[ -z "$bit" || "$bit" == "both" ]] && ln -sf "$novadir/nova" /usr/local/bin/nova
[[ -n "$bit" || "$bit" == "both" ]] && ln -sf "$novadir/nova32" /usr/local/bin/nova32

# make symlink for nova32 as nova
[[ -n "$bit" && "$bit" != "both" ]] && ln -sf "$novadir/nova32" /usr/local/bin/nova

## create files needed by nova and apply permissions
touch "$novadir/.KEY"
touch "$novadir/.DEVICES"

chmod u+wr,o+wr "$novadir/.DEVICES"
chmod u+wr,o+wr "$novadir/.KEY"

# apply perms to executable too
[[ -z "$bit" || "$bit" == "both" ]] && chmod u+rx,o+rx "$novadir/nova"
[[ -n "$bit" || "$bit" == "both" ]] && chmod u+rx,o+rx "$novadir/nova32"

printf "\nNova has been installed.\n\n"
printf "Please add Nova to your PATH. You can do so by adding this line at the end of your ~/.bashrc or ~/.profile file:\n"
printf "      export PATH=\"$novadir:\$PATH\"\n"
printf "Or if you're using fish shell do:\n"
printf "      set -U fish_user_paths $novadir \$fish_user_paths\n"
printf "in a terminal.\n"
