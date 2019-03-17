# Install GNOME Shell Extensions
A simple shell script that can automagically download, install, and enable all the [GNOME Shell Extensions](https://extensions.gnome.org/) on-the-fly!

### Why?
If you're a distro-hopper and want to quickly install extensions from the command-line, this script is for you.

Setting up a new GNOME desktop often involves installing [extensions](https://extensions.gnome.org/) you like or want.

This script simplifies the process (alot).

## How This Works

The [GNOME Shell Extensions website](https://extensions.gnome.org/) is a massive catalog of extensions for the GNOME desktop.

Each extension gets a unique number called extension ID (which is visible in the extension URL). Find and pass the IDs (of all the extensions you want installed) as arguments when running this script and rest is taken care of.


## Download

Usage is rather simple. 3 steps: Ensure dependencies are installed, get the IDs of extensions you want to install, run the script. 

### Preparation 

This script needs `curl, wget, jq, unzip, gnome-shell-extension-tool` (for API requests, JSON processing, downloading, installing, and enabling/disabling extensions).

You probably already have these installed, if not:

For Ubuntu: `$ sudo apt install -y curl wget jq unzip`

For Fedora: `$ sudo dnf install -y curl wget jq unzip`

### Download Script

Get the latest version of the script using the single-command:

`$ rm -f ./install-gnome-extensions.sh; wget -N -q "https://raw.githubusercontent.com/cyfrost/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh && chmod +x install-gnome-extensions.sh && ./install-gnome-extensions.sh`

The above command will: remove if the script file already exists, download the latest version from repo, set executable perms (user only) and run it.

## Installation

### 1. Get the IDs of Extensions you want to install

Each Shell Extension found on the site (https://extensions.gnome.org/) has a unique number called its Extension ID and is visible in its URL.

This script works using those IDs to download and install them.

For example, the popular [User Themes](https://extensions.gnome.org/extension/19/user-themes/) extension has the ID 19 as visible in its URL: https://extensions.gnome.org/extension/19/user-themes/.

Similarly, you can find and write down all the IDs of the extensions you want to install. This has to happen only once and those IDs can be reused anytime (in a script for example).

### 2. Run the script

After acquiring the IDs in step 1, you have to run the script mentioning those IDs for the installation to begin.

Run the following command to download and install them:

`$ ./install-gnome-extensions.sh <extension_id1> <extension_id2> .....`

For Example:

`$ ./install-gnome-extensions.sh --enable 8 750 1156` 

This example will install extensions with IDs [8](https://extensions.gnome.org/extension/8/places-status-indicator/), [750](https://extensions.gnome.org/extension/750/openweather/), [1156](https://extensions.gnome.org/extension/1156/gsnow/) and enable them.

For help and options, run:

`$ ./install-gnome-extensions.sh --help`

### 3. (Optional) Manually Enabling/Disabling Installed Extensions

This step is optional. By default, the script only downloads and installs extensions but does not enable them unless you've specified (Recommended) the `--enable` flag  when running the script.

But, if you want to manually enable/disable select extensions, you can do so by using the [GNOME Tweak Tool app](https://linuxconfig.org/how-to-install-tweak-tool-on-ubuntu-18-04-bionic-beaver-linux) with relative ease.

For Ubuntu: `$ sudo apt install -y gnome-tweak-tool && gnome-tweaks`

For Fedora: `$ sudo dnf install -y gnome-tweak-tool && gnome-tweaks`

Find and enable extensions from GNOME Tweak Tool app > "Extensions" page.

## Notes

1. As long as you have a GNOME desktop installed on the machine, you can use this script anytime and anywhere, even from KDE, XFCE etc (no graphical front-end required at all). The only hard requirements this script has is, a terminal environment and GNOME desktop installed.

2. No session reload necessary: This script internally makes use of the well-made `gnome-shell-extension-tool` binary to enable/disable extensions on-the-fly.

### TODO

1. Maybe add flags to remove/delete extensions on user's choice.
2. Maybe consult the distro's package manager (APT, DNF) if an extension the user is trying to install is already provided/available in the repos.
3. Provide a script function to check if an extension is correctly installed and enabled (this can help in deciding what extensions to update/overwrite/ignore).
4. [Trivial] Maybe make the script more convenient to use by allowing the user to supply a file containing the website links of extensions they want (no more mucking with extension IDs maybe?).
5. Add cli options to list info (name, id, url etc) of installed extensions (partially added with [51e3e9d](https://github.com/cyfrost/install-gnome-extensions/commit/51e3e9da4b9a208a01fd4f95440a0577290e3fbe)).
6. Add support to install extensions system-wide. currently extensions can only be installed for user specific.

## Contributing

Please [Create an Issue](https://github.com/cyfrost/install-gnome-extensions/issues) for any suggestions, bug report you may have with this script. Or, better yet, [Send a Pull Request](https://github.com/cyfrost/install-gnome-extensions/pulls) if you have the fixes ready.

## License

[MIT](https://github.com/cyfrost/install-gnome-extensions/blob/master/LICENSE)
