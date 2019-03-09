#!/bin/bash

# From https://github.com/cyfrost/install-gnome-extensions

# An extension ID is a unique number assigned to every extension found in https://extensions.gnome.org/ catalog.

# To obtain the ID of an extension you want to install, simply look for the number in its extension URL page. For example, the ID of the popular "User Themes" extension is 19, which is directly visible in it's URL: https://extensions.gnome.org/extension/19/user-themes/.

# You can specify the IDs of all the extensions you want to install in the below array (space delimited). In the default example, I've added the 3 ids of the most popular extensions as a sample.
extension_IDs_to_install=( "$@" )

# Defining text colors for statuses.
info_text=$(tput setaf 4);
normal_text=$(tput sgr0);
error_text=$(tput setaf 1);
status_text=$(tput setaf 2);

# Getting the current GNOME Shell version so that an extension corresponding to it can be pulled safely.
gnome_shell_version="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)";

# Install dependencies if needed (Ubuntus* ships with them, but Fedora doesn't afaik).
# sudo dnf install wget curl jq unzip -y
# sudo apt install wget curl jq unzip -y

install_shell_extensions(){

    for ext_id in "${extension_IDs_to_install[@]}"; do

        request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$gnome_shell_version";

        http_response_header="$(curl -s -o /dev/null -I -w "%{http_code}" $request_url)";

        if [ $http_response_header = 404 ]; then
            printf "\n${error_text}No extension exists with the given ID $ext_id (Skipping this).\n";
            continue;
        fi

        printf "${normal_text}\n";
        ext_info="$(curl -s $request_url)";
        extension_name="`echo $ext_info | jq -r .name`";
        direct_dload_url="`echo $ext_info | jq -r '.download_url'`";
        ext_uuid="`echo $ext_info | jq -r '.uuid'`";
        ext_version="`echo $ext_info | jq -r '.version'`";
        download_url="https://extensions.gnome.org"$direct_dload_url;
        filename=$(basename $download_url);
        target_installation_dir="/home/$USER/.local/share/gnome-shell/extensions/$ext_uuid";
        printf "${status_text}\nDownloading and installing \"$extension_name\"${normal_text}";
        printf "${info_text}"
        printf "\nExtension ID: $ext_id";
        printf "\nExtension Version: v$ext_version";
        printf "\nURL: $download_url";
        printf "\nUUID: \"$ext_uuid\"";
        #printf "\nFilename: $filename";
        printf "\nInstalling to: \"$target_installation_dir\"";
        printf "\nPlease wait..."
        wget -q $download_url;
        mkdir -p $target_installation_dir;
        unzip -o -q $filename -d $target_installation_dir;
        rm $filename;
        printf "\nDone!\n";
        printf "${normal_text}"
    done
    printf "\n";
}

printf "\n${status_text}Welcome. This script allows you to install your favourite GNOME Shell extensions with ease of use.\n${normal_text}";

if [ ${#extension_IDs_to_install[@]} -eq 0 ]; then

    printf "\n${info_text}No extension IDs have been specified for installation.\nPlease open this script in a text editor to specify the extension IDs for installation.${normal_text}\n\n";

else

    printf "\nGNOME Shell version detected: $gnome_shell_version\nStarting installation...\n";

    install_shell_extensions;

    printf "${status_text}Finished!\nExtensions were successfully installed but not enabled, you can enable them by using the GNOME Tweak Tool application.\n\n${normal_text}";

fi
