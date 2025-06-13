# Compile and Install GStreamer on Raspberry Pi OS

This guide explains how to build GStreamer from the official Git repository on Raspberry Pi OS. Each version is installed into its own directory under `/opt/gstreamer`, so multiple versions can coexist.

## Prerequisites

```bash
sudo apt update
sudo apt install --no-install-recommends git meson ninja-build build-essential \ 
    python3-pip python3-setuptools python3-wheel bison flex ragel gettext \
    cmake libglib2.0-dev libdrm-dev libgudev-1.0-dev libjpeg-dev \
    liborc-0.4-dev libtheora-dev libvorbis-dev libx264-dev libwayland-dev
```

## Clone the repositories

```bash
mkdir -p ~/src && cd ~/src
 git clone https://gitlab.freedesktop.org/gstreamer/gstreamer.git
```

## Build and install

Choose a version tag (for example `1.24.3`) and set an installation prefix:

```bash
cd gstreamer
git checkout 1.24.3
meson setup build --prefix=/opt/gstreamer/1.24.3
meson compile -C build
sudo meson install -C build
```

After installation you will find the `gst-launch-1.0` binary in `/opt/gstreamer/1.24.3/bin/`.

## Using the compiled version

Call the script with the `--gstver` option and provide the path to the desired `gst-launch-1.0` executable, e.g.

```bash
capture --gst --gstver /opt/gstreamer/1.24.3/bin/gst-launch-1.0
```

Older versions remain in their respective directories, allowing you to keep several versions in parallel.
