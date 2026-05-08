# LuCI Network Speed Test

### Screenshots

Screenshots are not included in this vendored copy.

### How to install

#### Prerequisites

This package depends on iperf3, librespeed-go, mikrotik-btest, and uhttpd. Make sure the target image has enough space for these runtime tools before installing luci-app-netspeedtest.

The Client SpeedTest page can open a public OpenSpeedTest page, a manually entered local OpenSpeedTest server such as `http://192.168.88.1:3000/`, or an OpenSpeedTest server hosted directly on the router. The router-hosted server uses the MIT-licensed static files from `openspeedtest/Speed-Test` and starts on port `3000` by default when enabled.

#### Installation

1. Goto ~~[releases](https://github.com/muink/luci-app-netspeedtest/tree/releases)~~ [here](https://fantastic-packages.github.io/releases/)
2. Download the latest version of ipk
3. Login router and goto **System --> Software**
4. Upload and install ipk
5. Reboot if the app is not automatically added in page
6. Goto **Network --> SpeedTest**

### Build

- Compile from OpenWrt/LEDE SDK

```
# Take the x86_64 platform as an example
tar xjf openwrt-sdk-21.02.3-x86-64_gcc-8.4.0_musl.Linux-x86_64.tar.xz
# Go to the SDK root dir
cd OpenWrt-sdk-*-x86_64_*
# First run to generate a .config file
make menuconfig
./scripts/feeds update -a
./scripts/feeds install -a
# Ensure this repository already contains package/luci-app-netspeedtest
# (the package is vendored in-tree, so no extra git clone step is needed)
# Select the package LuCI -> Applications -> luci-app-netspeedtest
make menuconfig
# Start compiling
make package/luci-app-netspeedtest/compile V=99
```

### License

- This project is licensed under the MIT License
