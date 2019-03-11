# Install GNOME Shell Extensions
This is a simple bash script that you can run to automatically download and install all the [GNOME Shell Extensions](https://extensions.gnome.org/) you want.

### Why?
Setting up a new GNOME desktop on any distro often involves downloading and installing some GNOME Shell extensions you like or want. This script automates that by only requiring the relevant extension IDs.

## How This Works

The [GNOME Shell Extensions website](https://extensions.gnome.org/) is a massive catalog of useful extensions contributed from many users for the GNOME desktop. Each extension gets a unique number called extension ID (which is visible in the extension URL). Find and pass the IDs of extensions you want installed as arguments when running this script and will be downloaded and installed (latest extension version available matching your GNOME Shell version).

## Download & Usage

### Preparation 

This script depends on: `curl, wget, jq, unzip, gnome-shell-extension-tool` (for API requests, JSON processing, downloading, installing, and enabling/disabling extensions).

You most probably already have these dependencies installed, otherwise you can do:

For Ubuntu: `$ sudo apt install -y curl wget jq unzip`

For Fedora: `$ sudo dnf install -y curl wget jq unzip`


## Getting the Extensions

### 1. Download the script

You can download and run this script directly from the browser or by using the command:

`$ rm -f ./install_gnome_extensions.sh; wget -N -q "https://github.com/cyfrost/install-gnome-extensions/raw/master/install_gnome_extensions.sh" -O ./install_gnome_extensions.sh && chmod +x install_gnome_extensions.sh && ./install_gnome_extensions.sh`

The above command will: remove if the script file already exists, download the latest version from repo, set executable perms (user only) and run it.

### 2. Get the IDs of Extensions you want to install

This script works by using the relevant Extension IDs to download and install them. Each extension takes a unique ID which is almost always visible in its URL page.

For example, the popular [User Themes](https://extensions.gnome.org/extension/19/user-themes/) extension has the ID 19 as visible in its URL: https://extensions.gnome.org/extension/19/user-themes/.

Similarly, find and write down all the IDs of the extensions you want to install.

### 3. Run the script

This script should NOT be run as root since it needs the user's local directory to operate.

Open a Terminal window in the location of the script and run it along with Extension IDs as arguments:

`$ ./install_gnome_extensions.sh <extension_id1> <extension_id2> .....`

All the specified extensions will be downloaded and installed automatically.

#### Example:

`$ ./install_gnome_extensions.sh --enable 6 8 19` 

This example will install extensions with IDs [6](https://extensions.gnome.org/extension/6/applications-menu/), [8](https://extensions.gnome.org/extension/8/places-status-indicator/), [19](https://extensions.gnome.org/extension/19/user-themes/) and enable them.

The default behviour is to only download and install said extensions but enabling them is left to the user's choice. It is possible to auto-enable extensions during install time by passing the `--enable` flag (Recommended).

For more options, run `$ ./install_gnome_extensions.sh --help` to see the command options.


### 4. (Optional) Manually Enabling/Disabling Installed Extensions

This step is optional. By default, the script only downloads and installs extensions but does not enable them unless you've specified the `--enable` flag (Recommended) when running the script.

But, if you want to manually enable/disable select extensions, you can do so by using the [GNOME Tweak Tool app](https://linuxconfig.org/how-to-install-tweak-tool-on-ubuntu-18-04-bionic-beaver-linux) with relative ease.

For Ubuntu: `$ sudo apt install -y gnome-tweak-tool && gnome-tweaks`

For Fedora: `$ sudo dnf install -y gnome-tweak-tool && gnome-tweaks`

You can find and enable extensions from GNOME Tweak Tool app > "Extensions" page.

## Contributing

Please [Create an Issue](https://github.com/cyfrost/install-gnome-extensions/issues) for any suggestions, bug report you may have with this script. Or, better yet, [Send a Pull Request](https://github.com/cyfrost/install-gnome-extensions/pulls) if you have the fixes ready.

## License

[MIT](https://github.com/cyfrost/install-gnome-extensions/blob/master/LICENSE)

