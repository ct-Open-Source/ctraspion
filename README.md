# c't-Raspion

<img src="files/logo.png" alt="c't Raspion Logo" width="100" align="right">Turns a Raspberry Pi into a WLAN router to take a look at network traffic of smart home and IoT devices. All apps are reachable via web browser. Published by [german computer magazine c't](https://ct.de/).

Its initial release incorporates [Pi-hole](https://pi-hole.net/), [ntopng](https://www.ntop.org/products/traffic-analysis/ntop/), [Wireshark](https://www.wireshark.org/), [Shell In A Box](https://github.com/shellinabox/shellinabox) and [mitmproxy](https://mitmproxy.org/).

## Requirements

Use a Raspberry Pi 3 or 4 for decent performance. Wireshark(-gtk) will be displayed by [Broadwayd](https://developer.gnome.org/gtk3/stable/broadwayd.html) within a web browser window.

## Download

Install as user pi on a fresh Rasbian Buster image (lite prefered) via:

```
wget ct.de/s/x5Pm -O raspion.zip 
unzip raspion.zip
cd raspion
./install2.sh
```

[Manual download of the zip archive](https://ct.de/projekte/ctraspion/raspion.zip)

## Further reading

### Articles in c't (German)

In c't 1/2020:

[c’t-Raspion: Datenpetzen finden und bändigen](https://www.heise.de/ct/ausgabe/2020-1-c-t-Raspion-Datenpetzen-finden-und-baendigen-4611153.html)

[c't-Raspion: Projektseite – Foren weitere Hinweise](https://www.heise.de/ct/artikel/c-t-Raspion-Projektseite-4606645.html)
