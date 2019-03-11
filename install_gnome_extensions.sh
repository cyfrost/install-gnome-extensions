#!/bin/bash

# From https://github.com/cyfrost/install-gnome-extensions

_term() { 
  printf "\n\n${normal_text}";
  trap - INT TERM # clear the trap
  kill -- -$$
}

trap _term INT TERM

if [ "$(id -u)" = 0 ]; then
   printf "\nRunning this script as root is discouraged and won't work since it needs user directories to operate. Retry as normal user.\n\n"
   exit 1
fi

# An extension ID is a unique number assigned to every extension found in https://extensions.gnome.org/ catalog.
# To obtain the ID of an extension you want to install, simply look for the number in its extension URL page. For example, the ID of the popular "User Themes" extension is 19, which is directly visible in it's URL: https://extensions.gnome.org/extension/19/user-themes/.

# You can specify the IDs of all the extensions you want to install in the below array (space delimited). In the default example, I've added the 3 ids of the most popular extensions as a sample.
extension_IDs_to_install=("$@")

extensions_count=${#extension_IDs_to_install[@]}

# Defining text colors for statuses.
info_text=$(tput setaf 4);
normal_text=$(tput sgr0);
error_text=$(tput setaf 1);
status_text=$(tput setaf 3);

function CheckDependencies(){

echo -en "\nChecking dependencies... ";
dependencies=("$@")
for name in "${dependencies[@]}"
do
  command -v "$name" >/dev/null 2>&1 || { echo -en "${error_text}\nError: command not found: $name${normal_text}";deps=1; }
done
[[ $deps -ne 1 ]] && echo "OK" || { echo -en "${error_text}\n\nPlease install the above commands and rerun this script\n\n${normal_text}";exit 1; }
}

dependencies=(wget curl jq unzip gnome-shell-extension-tool)

CheckDependencies "${dependencies[@]}"

# Getting the current GNOME Shell version so that an extension corresponding to it can be pulled safely.
gnome_shell_version="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)";

# Install dependencies if needed (Ubuntus* ships with them, but Fedora doesn't afaik).
# sudo dnf install wget curl jq unzip -y
# sudo apt install wget curl jq unzip -y

function install_shell_extensions(){

    for ext_id in "${extension_IDs_to_install[@]}"; do

        request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$gnome_shell_version";

        http_response_header="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")";

        if [ "$http_response_header" = 404 ]; then
            printf "\n${error_text}Error: No extension exists with ID $ext_id (Skipping this).\n";
            continue;
        fi

        printf "${normal_text}\n";
        ext_info="$(curl -s "$request_url")";
        extension_name="$(echo "$ext_info" | jq -r '.name')"
        direct_dload_url="$(echo "$ext_info" | jq -r '.download_url')";
        ext_uuid="$(echo "$ext_info" | jq -r '.uuid')";
        ext_version="$(echo "$ext_info" | jq -r '.version')";
        ext_homepage="$(echo "$ext_info" | jq -r '.link')";
        ext_description="$(echo "$ext_info" | jq -r '.description')";
        download_url="https://extensions.gnome.org"$direct_dload_url;
        target_installation_dir="/home/$USER/.local/share/gnome-shell/extensions/$ext_uuid";
        printf "${status_text}\nDownloading and installing \"$extension_name\"${normal_text}";
        printf "${info_text}"
        printf "\nDescription: $ext_description";
        printf "\nExtension ID: $ext_id";
        printf "\nExtension Version: v$ext_version";
        printf "\nHomepage: https://extensions.gnome.org$ext_homepage";
        printf "\nUUID: \"$ext_uuid\"";
        printf "\nInstalling to: \"$target_installation_dir\"";

        if [ -d "$target_installation_dir" ]; then
            confirm_action "${normal_text}This extension is already installed. Would you like to overwrite it? (y/n): " || continue;
        fi

        printf "${info_text}Please wait..."
        filename="$(basename "$download_url")";
        wget -q "$download_url";
        mkdir -p "$target_installation_dir";
        unzip -o -q "$filename" -d "$target_installation_dir";
        rm "$filename";
        printf "\nDone!\n";
        printf "${normal_text}"
    done
    printf "\n";
}

function confirm_action() {
    while true; do
    printf "\n${normal_text}";
    read -rep "$1" yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer with 'y' or 'n'.";;
    esac
done
}

printf "\n================================\nGNOME Shell Extensions Installer\n================================\nThis script allows you to install your favourite GNOME Shell extensions with ease of use.\nSee https://github.com/cyfrost/install-gnome-extensions/blob/master/README.md for more info.\n${normal_text}";

if [ "$extensions_count" -eq 0 ]; then
    printf "\n${status_text}Usage: sh install_gnome_extensions.sh <extension_id1> <extension_id2> <extension_id3> ...${normal_text}\n\nExample usage: ./install_gnome_extensions.sh 6 8 19\n\n";
else
    printf "\nGNOME Shell version detected: $gnome_shell_version\nStarting installation for $extensions_count extensions...\n";
    install_shell_extensions;
    printf "${status_text}Finished!\nYou may want to use GNOME Tweak Tool to enable these extensions.\n\n${normal_text}";
fi
