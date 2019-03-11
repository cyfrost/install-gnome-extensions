#!/bin/bash

# ========================================================================================================
# This bash script allows users to install GNOME Shell Extensions by taking Extension IDs as arguments.
# This will only work on an actively running GNOME desktop instance.
# Homepage: https://github.com/cyfrost/install-gnome-extensions
# License: MIT
# Author: Cyfrost
# ========================================================================================================


# message colors.
info_text_blue=$(tput setaf 4);
normal_text=$(tput sgr0);
error_text=$(tput setaf 1);
status_text_yellow=$(tput setaf 3);

#vars
args_count="$#"
dependencies=(wget curl jq unzip gnome-shell-extension-tool gnome-shell cut basename)
EXTENSIONS_TO_INSTALL=()
OVERWRITE_EXISTING=false
ENABLE_ALL=false

# Bail immediately if running as root.
function CheckIfRunningAsRoot(){
    if [ "$(id -u)" = 0 ]; then
        printf "\nRunning this script as root is discouraged and won't work since it needs user directories to operate. Retry as normal user.\n\n"
        exit 1
    fi
}

# Trap SIGINT and SIGTERM.
function _term() {
    printf "\n\n${normal_text}";
    trap - INT TERM # clear the trap
    kill -- -$$
}

# This function can check for binaries/commands to be available in Env PATH and report otherwise.
function CheckDependencies(){

    echo -en "\n${info_text_blue}Checking dependencies...${normal_text}";
    dependencies=("$@")
    for name in "${dependencies[@]}"
    do
        command -v "$name" >/dev/null 2>&1 || { echo -en "${error_text}\nError: command not found: $name${normal_text}";deps=1; }
    done
    [[ $deps -ne 1 ]] && echo "${info_text_blue}OK${normal_text}" || { echo -en "${error_text}\n\nPlease make sure the above commands are available and re-run this script.\n\n${normal_text}";exit 1; }
}

function confirm_action() {
    while true; do
        printf "\n${normal_text}";
        read -rep "$1" -n 1 yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer with 'y' or 'n'.";;
        esac
    done
}

function enable_extension(){
    ext_uuid="$1"
    gnome-shell-extension-tool -e "$ext_uuid" >/dev/null 2>&1
}

function disable_extension(){
    ext_uuid="$1"
    gnome-shell-extension-tool -d "$ext_uuid" >/dev/null 2>&1
}

function install_shell_extensions(){
    
    for ext_id in "${EXTENSIONS_TO_INSTALL[@]}"; do

        request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$GNOME_SHELL_VERSION";
        http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")";

        if [ "$http_response" = 404 ]; then
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
        printf "${status_text_yellow}\nDownloading and installing \"$extension_name\"${normal_text}";
        printf "${info_text_blue}"
        printf "\nDescription: $ext_description";
        printf "\nExtension ID: $ext_id";
        printf "\nExtension Version: v$ext_version";
        printf "\nHomepage: https://extensions.gnome.org$ext_homepage";
        printf "\nUUID: \"$ext_uuid\"";
        printf "\nInstalling to: \"$target_installation_dir\"";

        if [ -d "$target_installation_dir" ]  && [ "$OVERWRITE_EXISTING" = "false" ]; then
            confirm_action "${normal_text}This extension is already installed. Would you like to overwrite it? (y/n): " || continue;
        else
            printf "\n"
        fi

        printf "${info_text_blue}Please wait..."
        filename="$(basename "$download_url")";
        wget -q "$download_url";
        mkdir -p "$target_installation_dir";
        unzip -o -q "$filename" -d "$target_installation_dir";
        sleep 1
        rm "$filename";

        if [ "$ENABLE_ALL" = "false" ]; then
            confirm_action "${normal_text}Enable this extension now? (y/n): " && enable_extension "$ext_uuid";
        fi
        
        printf "${info_text_blue}Done!\n";
        printf "${normal_text}"
    done
    printf "\n";
}

# Check if arg is number.
function IsNumber(){
    re='^[0-9]+$'
    if [[ "$1" =~ $re ]] ; then
        return 0;
    fi
    return 1;
}

function print_usage(){
    printf "\n${normal_text}Usage: ./install_gnome_extensions.sh <extension_id1> <extension_id2> <extension_id3> ...\n\nExample usage: ./install_gnome_extensions.sh 6 8 19\n\n";
}

function begin_install(){

    printf "\nGNOME Shell version detected: $GNOME_SHELL_VERSION\nStarting installation for $extensions_count extensions...\n";
    install_shell_extensions;
    printf "${normal_text}Complete!\n\n$";
}

# Bail immediately if running as root.
CheckIfRunningAsRoot

# Fail if dependencies unmet.
CheckDependencies "${dependencies[@]}"

# Obtain GNOME Shell version.
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)";

# Trap SIGINT and SIGTERM for cleanup.
trap _term INT TERM

printf "${status_text_yellow}\n================================\nGNOME Shell Extensions Installer\n================================\n\nThis script allows you to install your favourite GNOME Shell extensions with ease of use.\n\nHomepage: https://github.com/cyfrost/install-gnome-extensions${normal_text}\n";


while test $# -gt 0; do
    case "$1" in
        --enable)
            echo "extensions will be enabled upon install"
    		ENABLE_ALL=true
            ;;
        --update) 
		   	echo "extensions will be updated to latest available versions"
		    UPDATE=true
            ;;
        --overwrite) 
		    echo "extensions will be overwritten if no newer version is found"
			OVERWRITE_EXISTING=true
            ;;
    esac
    IsNumber "$1" && EXTENSIONS_TO_INSTALL+=($1)
    shift
done

extensions_count="${#EXTENSIONS_TO_INSTALL[@]}"

if [ "$args_count" -eq 0 ] || [ "$extensions_count" -eq 0 ]; then
    print_usage
else
    begin_install
fi


# Install dependencies if needed (Ubuntus* ships with them, but Fedora doesn't afaik). detect os and install echo commands.
# sudo dnf install wget curl jq unzip -y
# sudo apt install wget curl jq unzip -y
