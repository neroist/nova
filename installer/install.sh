#!/bin/bash

# set -e

# check if sudo
if [ "$(id -u)" -ne 0 ]; then
  printf "Please run as root/sudo!\n"
  exit 1
fi

# vars
novaver="1.7.0"
novadir="/opt/nova"
input=""

read -p "What directory should Nova install to? (defaults to $novadir) " input

if [ -n "$input" ]; then # if input is not empty...
  novadir=$input
fi

printf "Installing to $novadir/\n\n"

mkdir -p $novadir
wget -q -O "$novadir/nova" "https://github.com/neroist/nova/releases/download/$novaver/nova"

# make symlink to nova in secure path
ln -s /usr/local/nova/nova /usr/local/bin/nova

# create files needed by nova and apply permissions
touch "$novadir/.KEY"
touch "$novadir/.DEVICES"

chmod u+wr,o+wr "$novadir/.DEVICES"
chmod u+wr,o+wr "$novadir/.KEY"

# apply perms to executable too
chmod u+rx,o+rx "$novadir/nova"

printf "Nova has been installed.\n\n"
printf "Please add Nova to your PATH. You can do so by adding this line at the end of your ~/.bashrc or ~/.profile file:\n"
printf "      export PATH=\"$novadir:\$PATH\"\n"
printf "Or if you're using fish shell do:\n"
printf "      set -U fish_user_paths $novadir \$fish_user_paths\n"
printf "in a terminal.\n"
