novadir="/opt/nova/"
input=""
 
read -p "What directory should Nova install to? (defaults to $novadir) " input

if [ -n "$input" ] # if input is not empty
then
  novadir=$input
fi

echo "Installing to $novadir"

mkdir -p $novadir
wget -q -O "$novadir/nova" https://github.com/neroist/nova/releases/download/1.7.0/nova

echo "Nova has been installed.\n"

echo "Please add Nova to your PATH. You can do so by adding this line at the end of your .bashrc or .profile file"
echo "      export PATH="$novadir:\$PATH""

echo "\nOr if you're using fish shell do:"
echo "      set -U fish_user_paths $novadir \$fish_user_paths"
echo "in a terminal"
