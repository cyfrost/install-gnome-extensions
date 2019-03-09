## What
A simple bash script that automates downloading and installing of GNOME Shell Extensions you tell it to.

## Why
Setting up a new distro installation running GNOME desktop often involves installing some GNOME Shell extensions that you like or want. This script saves me time in that I just have to open the script once, input all the extension IDs, and everything else is taken care of.

## Download & Usage

### Dependencies

This script requires these dependencies: `curl, wget, jq, unzip` for API requests to Extensions site, JSON processing for extension info, Wget for downloading the extensions, and Unzip for installing the extensions.

You most probably already have these dependencies installed, otherwise they're just a install command away from your distro's repos.

For Fedora: `sudo dnf install -y curl wget jq unzip`

### Using the script

#### 1. Download the script

You can download the script directly from the browser or by using a command like `wget -O install_gnome_extensions.sh https://raw.githubusercontent.com/cyfrost/install-gnome-extensions/master/install_gnome_extensions.sh`

#### 2. Get the IDs of all Extensions you want to install

First, it is important to understand that this script downloads and installs the GNOME Shell Extensions based on their Extension IDs. Each extension is given a unique ID which is almost always visible in its URL page.

For example, the popular [User Themes](https://extensions.gnome.org/extension/19/user-themes/) extension has the ID 19 as visible in its URL: https://extensions.gnome.org/extension/19/user-themes/.

Similarly, Just write down all the IDs of the extensions you want to install.

Now open the script downloaded in step 1 using a text editor and paste those ids in the `extension_IDs_to_install` array (each ID separated with space). Save it and close.

#### 3. Run the script

This script does not require root permissions since it only needs the User's local directory to operate.

Open a Terminal window in the location of the script and run

`sh install_gnome_extensions.sh`

All the extensions specified should now be downloaded and installed automatically.

#### 4. Enabling installed extensions

Now, you want to enable the installed extensions. You can do so by using the [GNOME Tweak Tool app](https://linuxconfig.org/how-to-install-tweak-tool-on-ubuntu-18-04-bionic-beaver-linux) with relative ease.


### Alternate way

Single command to download the latest version of the script, make it executable, and run it.

`wget -O install_gnome_extensions.sh https://raw.githubusercontent.com/cyfrost/install-gnome-extensions/master/install_gnome_extensions.sh && sh install_gnome_extensions.sh`



#### Stranger Danger

You're probably freaking and noping out that running scripts from internet is bad and must be avoided at all costs. Well, that is true. If you're half as paranoid as me, you can fork this script if you like and use that instead :)

## License
MIT

