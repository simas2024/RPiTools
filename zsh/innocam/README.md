# Raspberry Pi 5 Inno Cam (IMX708) Stream and Capture

This repository contains a script for live streaming and capturing images using the Innomaker IMX708 camera module on a Raspberry Pi 5. The script streams video over UDP to a client and allows capturing still images on the Pi.

<table align="center">
  <tr>
    <th>Inno Cam and Raspberry Pi 5 assembled and mounted on a tripod 😊</th>
  </tr>
  <tr>
    <td align="center">
      <img src="img/cam.jpg" height="400">
    </td>
  </tr>
</table>


## Platform

Streaming was tested with minimum delay over a 1 Gbit/s LAN on the following platforms:

### Raspberry Pi OS (Server)

- OS: Debian GNU/Linux bookworm 12.11 aarch64
- Host: Raspberry Pi 5 8GB
- Kernel: Linux 6.12.25+rpt-rpi-2712
- Shell: zsh 5.9

### macOS (Client)

- OS: macOS Sequoia 15.5 arm64
- Kernel: Darwin 24.5.0
- Shell: zsh 5.9

### Windows 11 (Client)

- OS: Windows 11 Pro x86_64
- Kernel: WIN32_NT 10.0.26100.4202 (24H2)
- Shell: Windows PowerShell 5.1.26100.4202

### Camera

- Innomaker Sensor: IMX708 AF [4608x2592 10-bit RGGB]

## Features

- Start the script via SSH and zsh on the Raspberry Pi.
- Start a live video stream with `rpicam-vid` (UDP).
- Preview the stream on the client using `ffplay` or VLC.
- Press `c` in the script to capture a still image with `rpicam-still`, saved locally on the Pi.

## Requirements

- zsh
- ffplay
- rpicam-apps

## Installation

### Raspberry Pi OS

1. Update the system:
    ```bash
    sudo apt update && sudo apt upgrade
    ```

2. Install camera tools:
    ```bash
    sudo apt install rpicam-apps
    ```

3. Test the camera:
    ```bash
    rpicam-hello --list-cameras
    ```

### macOS

1. Install Homebrew if needed:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. Install ffmpeg (provides ffplay):
    ```bash
    brew install ffmpeg
    ```

### Windows 11

1. Install FFmpeg (includes ffplay) via winget:
    ```powershell
    winget install --id=Gyan.FFmpeg --source=winget
    ```

2. (This might already be done when ffplay starts for the first time) Allow UDP port 5000 in Windows Firewall:
    - Search "Windows Defender Firewall".
    - Open "Advanced Settings" → "Inbound Rules" → "New Rule".
    - Select "Port", choose "UDP", set "5000", and allow the connection.

## Streaming

On the client:

macOS

```bash
ffplay -fflags nobuffer -flags low_delay udp://@:5000
```

Windows 11

```Powershell
ffplay -fflags nobuffer -flags low_delay udp://0.0.0.0:5000
```

On the Raspberry Pi (via SSH):

```bash
git clone https://github.com/simas2024/RPiTools.git
```

Navigate to the directory where the repository was cloned and add a link:

```bash
cd RPiTools
ln -s zsh/innocam/scripts/capture01.zsh capture
chmod +x capture
```

Start streaming:

```bash
./capture
```

Press `c` to capture a still image (saved on the Pi).

Press `s` to stop the stream and exit the script.

Note: Adjust the IP address (192.168.2.101) in the script to match your client IP.

## Example

Object held freehand in front of the camera, captured via `c` during streaming:

<table>
  <tr>
    <th> <code>--saturation 0.0</code></th>
    <th> <code>--saturation 1.0</code></th>
  </tr>
  <tr>
    <td><img src="img/bild_bw_20250605_080155.jpg" height="300"></td>
    <td><img src="img/bild_20250605_080155.jpg" height="300"></td>
  </tr>
</table>

## References
 
- [Raspberry Pi Camera Software Documentation](https://www.raspberrypi.com/documentation/computers/camera_software.html)

- [Innomaker Camera](https://github.com/INNO-MAKER/cam-imx708af)
 

