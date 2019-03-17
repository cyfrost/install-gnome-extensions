#!/bin/bash

   #################################################################
   #                                                               #
   #             GNOME Shell Extension Installer 1.0.2             #
   #                                                               #
   #       Copyright (C) 2019 Cyfrost <cyrus.frost@hotmail.com>    #
   #       License: MIT                                            #
   #                                                               #
   #     https://github.com/cyfrost/install-gnome-extensions       #
   #                                                               #
   #################################################################

#vars
script_revision="v1.0.2"
args_count="$#"
dependencies=(wget curl jq unzip tput sed gnome-shell-extension-tool gnome-shell cut basename)
deps_install_apt="sudo apt install -y wget curl jq unzip sed"
deps_install_dnf="sudo dnf install -y wget curl jq unzip sed"
EXTENSIONS_TO_INSTALL=()
OVERWRITE_EXISTING=false
ENABLE_ALL=false
INSTALLED_EXT_COUNT='';
INSTALLED_EXTs='';

# message colors.
info_text_blue=$(tput setaf 2);
normal_text=$(tput sgr0);
error_text=$(tput setaf 1);
status_text_yellow=$(tput setaf 3);

# Bail immediately if running as root.
function CheckIfRunningAsRoot(){
    if [ "$(id -u)" = 0 ]; then
        printf "\n${error_text}Running this script as root is discouraged and won't work since it needs user directories to operate. Retry as normal user.\n\nNote: If you're trying to install extensions for another user on this computer, try 'su <user_account_name>' and proceed.\n\nAbort.\n\n${normal_text}"
        exit 1
    fi
}

# Bail immediately if running as root.
CheckIfRunningAsRoot

# Trap SIGINT and SIGTERM.
function _term() {
    printf "\n\n${normal_text}";
    trap - INT TERM # clear the trap
    kill -- -$$
}

# Trap SIGINT and SIGTERM for cleanup.
trap _term INT TERM

# This function can check for binaries/commands to be available in Env PATH and report otherwise.
function CheckDependencies(){

    # echo -en "\n${info_text_blue}Checking dependencies...${normal_text}";
    dependencies=("$@")
    for name in "${dependencies[@]}"
    do
        command -v "$name" >/dev/null 2>&1 || { echo -en "${error_text}\n[Error] Command not found: \"$name\"${normal_text}";deps=1; }
    done
    [[ $deps -ne 1 ]] || { echo -en "${error_text}\n\nOne or more dependencies is unavailable. Please make sure the above commands are available and re-run this script.\n\n${status_text_yellow}For Ubuntu and similar distros, try: $deps_install_apt\n\nFor Fedora and similar distros, try: $deps_install_dnf\n\n${normal_text}";exit 1; }
}

# Fail if dependencies unmet.
CheckDependencies "${dependencies[@]}"

function confirm_action() {
    while true; do
        printf "\n${normal_text}";
        read -p "$1" -n 1 yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer with 'y' or 'n'.";;
        esac
    done
}

function IsEnvGNOME(){

    if [ "$XDG_CURRENT_DESKTOP" = "" ]; then
        desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(xfce\|kde\|gnome\).*/\1/')
    else
        desktop=$XDG_CURRENT_DESKTOP
    fi

    desktop=${desktop,,}
 
    if [[ $desktop == *"gnome"* ]]; then
        return 0
    else
        return 1
    fi
}

function enable_extension(){
    ext_uuid="$1"
    gnome-shell-extension-tool -e "$ext_uuid" >/dev/null 2>&1
}

function disable_extension(){
    ext_uuid="$1"
    gnome-shell-extension-tool -d "$ext_uuid" >/dev/null 2>&1
}

function get_installed_extensions_list(){
user_extensions_path="/home/$USER/.local/share/gnome-shell/extensions";
array=($(ls -l $user_extensions_path --time-style=long-iso | egrep '^d' | awk '{print $8}'));
ext_list=$(printf "'%s'," "${array[@]}");
ext_list=${ext_list%,};
INSTALLED_EXT_COUNT="${#array[@]}"
INSTALLED_EXTs=$(printf '%s\n' "${array[@]}");
# echo $ext_list
}

function install_shell_extensions(){
    
    for ext_id in "${EXTENSIONS_TO_INSTALL[@]}"; do

        request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$GNOME_SHELL_VERSION";
        http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")";

        if [ "$http_response" = 404 ]; then
            printf "\n${error_text}Error: No extension exists matching the ID: $ext_id and GNOME Shell version $GNOME_SHELL_VERSION (Skipping this).\n";
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
        printf "${status_text_yellow}\nDownloading and installing extension \"$extension_name\"${normal_text}";
        printf "${info_text_blue}"
        printf "\nDescription: $ext_description";
        printf "\nExtension ID: $ext_id";
        printf "\nExtension Version: v$ext_version";
        printf "\nHomepage: https://extensions.gnome.org$ext_homepage";
        printf "\nUUID: \"$ext_uuid\"";
        printf "\nInstalling to: \"$target_installation_dir\"";

        if [ -d "$target_installation_dir" ]  && [ "$OVERWRITE_EXISTING" = "false" ]; then
            confirm_action "${normal_text}This extension is already installed. Do you want to overwrite it? (y/n): " || continue;
        fi

        printf "\n${info_text_blue}Please wait..."
        filename="$(basename "$download_url")";
        wget -q "$download_url" &&
        mkdir -p "$target_installation_dir" &&
        unzip -o -q "$filename" -d "$target_installation_dir" &&
        sleep 1 &&
        rm "$filename";

        if [ "$ENABLE_ALL" = "false" ]; then
            confirm_action "${normal_text}Enable this extension now? (y/n): " && enable_extension "$ext_uuid";
        else
            enable_extension "$ext_uuid"
        fi
        
        printf "\n${info_text_blue}Done!\n";
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
    printf "\n${normal_text}Usage: ./install-gnome-extensions.sh [options] <extension_ids>\n\nOptions:\n\t--enable\tEnables the extension after downloading and installing it.\n\t--update\tUpdates existing extensions to latest available versions.\n\t--overwrite\tOverwrites existing extensions, disabled by default.\n\t--list-installed    Lists the UUIDs of installed extensions.\n\nExample usage: ./install-gnome-extensions.sh 6 8 19 --enable\n\n";
}

function print_banner(){
printf "${normal_text}\n=======================================\nGNOME Shell Extensions Installer $script_revision\n=======================================\n\nA simple (scriptable) way to install your favourite GNOME Shell extensions.\n\nGitHub: https://github.com/cyfrost/install-gnome-extensions${normal_text}\n";
}

function begin_install(){

    printf "\n${info_text_blue}[Info] Detected GNOME Shell version: $GNOME_SHELL_VERSION\n\nStarting installation for $extensions_count extensions...\n${normal_text}";
    install_shell_extensions;
    printf "\n${normal_text}Complete!\n\n";
    IsEnvGNOME || printf "${normal_text}Please login to GNOME desktop to see the installed/enabled extensions.\n\n"
}

while test $# -gt 0; do
    case "$1" in
        --enable)
            ENABLE_ALL=true
            ;;
        --update) 
            UPDATE=true
            ;;
        --overwrite) 
            OVERWRITE_EXISTING=true
            ;;
        --help) 
            print_usage; exit 0;
            ;;
        --list-installed) 
            get_installed_extensions_list; echo -en "\n============================\nInstalled extensions (UUIDs)\n============================\n\n$INSTALLED_EXTs\n\n$INSTALLED_EXT_COUNT extensions are installed.\n\nDone!\n\n"; exit 0;
            ;;
    esac
    IsNumber "$1" && EXTENSIONS_TO_INSTALL+=($1)
    shift
done

# Obtain GNOME Shell version.
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)";

extensions_count="${#EXTENSIONS_TO_INSTALL[@]}"

print_banner

if [ "$args_count" -eq 0 ] || [ "$extensions_count" -eq 0 ]; then
    print_usage
else
    begin_install
fi
