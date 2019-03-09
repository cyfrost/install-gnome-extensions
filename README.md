## What
A bash script that automates downloading and installing of GNOME Shell Extensions you tell it to.

## Why
Setting up a new Fedora/Ubuntu installation with GNOME DE often involves installing some useful/favourite extensions. This script saves me time in that I just have to input those IDs once and everything else is taken care of.

## Download & Usage

### Dependencies

This script uses `wget, curl, jq` etc for API requests, JSON processing, and WGET downloading as dependencies.

These are available in your distro's standard repos and most probably already installed, if not, do install.

### Using the script

Single command to download the latest version of the script, make it executable, and run it.

`wget -O install_gnome_shell_extension.sh https://raw.githubusercontent.com/cyfrost/gnome-shell-extension-installer/master/install_gnome_shell_extension.sh && chmod +x install_gnome_shell_extension.sh && ./install_gnome_shell_extension.sh`

#### Stranger Danger

You're probably freaking and noping out that running scripts from internet is bad and must be avoided at all costs. Well, that is true. If you're half as paranoid as me, you can fork this script if you like and use that instead :)

## License
MIT

