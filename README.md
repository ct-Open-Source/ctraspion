# c't-Raspion - DEVELOPMENT 1.1.0

<img src="files/logo.png" alt="drawing" width="100" align="right">Turns a Raspberry Pi into a WLAN router to take a look at network traffic of smart home and IoT devices. All apps are reachable by a web browser. Published by [german computer magazine c't](https://ct.de/).

Its initial releases incorporated [Pi-hole](https://pi-hole.net/), [ntopng](https://www.ntop.org/products/traffic-analysis/ntop/), [Wireshark](https://www.wireshark.org/), [Shell In A Box](https://github.com/shellinabox/shellinabox) and [mitmproxy](https://mitmproxy.org/).

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for details

## Requirements

Use a Raspberry Pi 3 or 4 for decent performance. Wireshark(-gtk) will be displayed by [Broadwayd](https://developer.gnome.org/gtk3/stable/broadwayd.html) within a web browser window.

## Usage

git clone --branch feature-debbaseddev https://github.com/ct-Open-Source/ctraspion.git
cd ctraspion/
./rsd.sh all

These will run the following:
 - ./rsd.sh prepare - Installs Depencies for building raspion
 - ./rsd.sh build - Builds packages under pkg/
 - ./rsd.sh buildrepository - Builds and setup the local apt-repository
 - ./rsd.sh install - just runs release/install.sh

## Structure
 - development/ - contains the patches from c't-Magazine and the repository
 - development/repository/ - flat local apt repository 
 - pkgs/ - contains subdirectorys for each package (actually only raspion)
 - pkgs/[pkg]/build.sh - will be sourced from rsd.sh and should build a deb-file, which mzust be moved to development/repository
 - release/ - contains org debs and all files needed for the installation
 - scripts/ - functions to be sourced from rsd.sh
 - rsd.sh - main buildscript


### Articles in c't (German)

In c't 1/2020:

[c’t-Raspion: Datenpetzen finden und bändigen](https://ct.de/-2805710)

[c't-Raspion: Projektseite – Foren weitere Hinweise](https://www.heise.de/ct/artikel/c-t-Raspion-Projektseite-4606645.html)
