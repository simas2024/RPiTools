# RPiTools

A growing repository and a small collection of tools and scripts for the Raspberry Pi 5. It includes utilities for managing, and utilizing the GPIO (General Purpose Input/Output) pins.

- [Raspberry Pi 5 HW PWM Control](#raspberry-pi-5-hw-pwm-control)

## Platform

The scripts were tested and run on Raspberry Pi OS and AlmaLinux.

### Raspberry Pi OS

    OS: Debian GNU/Linux bookworm 12.6 aarch64
    Host: Raspberry Pi 5 Model B Rev 1.0
    Kernel: Linux 6.6.31-v8-16k+
    Shell: bash 5.2.15

### AlmaLinux

    OS: AlmaLinux 9.4 aarch64
    Host: Raspberry Pi 5 Model B Rev 1.0
    Kernel: Linux 6.6.31-20240529.v8.2.el9
    Shell: bash 5.1.8
      
## RPi and GPIO

                                                  +----+-------||-------+----+
                                                  |    | Name  || Name  |    |
      ~ ---------------------------------         +----+-------||-------+----+
      ~                          1  o  o  2  ---- |    |  3.3v ||    5v |    |
      ~                          3  o  o  4       |  2 | SDA.1 ||    5V |    |
      ~                          5  o  o  6       |  3 | SCL.1 ||    0v |    |
      ~                          7  o  o  8       |  4 |  GPIO || TxD.1 | 14 |
      ~                          9  o  o  10      |    |    0v || RxD.1 | 15 |
      ~                         11  o  o  12      | 17 |  GPIO ||  GPIO | 18 |
      ~                         13  o  o  14      | 27 |  GPIO ||    0v |    |
      ~                         15  o  o  16      | 22 |  GPIO ||  GPIO | 23 |
      ~       -------------     17  o  o  18      |    |  3.3v ||  GPIO | 24 |
      ~      |             |    19  o  o  20      | 10 |  MOSI ||    0v |    |
      ~      |   BCM2712   |    21  o  o  22      |  9 |  MISO ||  GPIO | 25 |
      ~      |             |    23  o  o  24      | 11 |  SCLK ||   CE0 |  8 |
      ~       -------------     25  o  o  26      |    |    0v ||   CE1 |  7 |
      ~                         27  o  o  28      |  0 | SDA.0 || SCL.0 |  1 |
      ~                         29  o  o  30      |  5 |  GPIO ||    0v |    |
      ~                         31  o  o  32      |  6 |  GPIO ||  GPIO | 12 |
      ~                         33  o  o  34      | 13 |  GPIO ||    0v |    |
      ~                         35  o  o  36      | 19 |  GPIO ||  GPIO | 16 |
      ~                         37  o  o  38      | 26 |  GPIO ||  GPIO | 20 |
      ~                         39  o  o  40 ---- |    |    0v ||  GPIO | 21 |
      ~                 ---------       |         +----+-------||-------+----+
      ~                |         |      |
      ~                |   RP1   |      |
      ~                |         |      |
      ~                 ---------       |
      ~    -----      -----      -----  |
      ~   | ETH |    | USB |    | USB | |
      ~   |     |    |     |    |     | |
      ~ --       ----       ---      ----

# Raspberry Pi 5 HW PWM Control

A ZSH library and scripts for controlling hardware PWM on a Raspberry Pi 5 B using the `sysfs` interface.

- `./zsh/pwm/pwm.zsh` A ZSH library for controlling hardware PWM (Pulse Width Modulation) on a Raspberry Pi 5 B using the `sysfs` interface.
- `./zsh/pwm/run.zsh` A demo script that shows how to use the PWM ZSH library. It demonstrates the basic functions and use cases of PWM control.
- `./zsh/pwm/stop.zsh` A small script that can be used to stop a running `run.zsh` script in the background `./zsh/pwm/run.zsh &`.

### Features
- **ZSH Script for Hardware PWM**: Control PWM on Raspberry Pi 5 pins 12, 13, 18 and 19.
- **Demo Script**: Included is an example in `./zsh/pwm/run.zsh` for controlling an RC servo and LEDs.

### Requirements
- `zsh` v5.8
- Add `dtoverlay=pwm-2chan` to `/boot/firmware/config.txt` (Raspberry Pi OS) or `/boot/config.txt` (AlmaLinux), respectively. So we can use GPIO 12, 13, 18 and 19 for PWM function. See [Git Repositories - Overlays](#git-repositories)

The library and script use some tools and builtin commands that come with Raspberry Pi OS and ZSH:
- `printf`, `echo`, `zparseopts`, `trap`, `shift`, `sleep`, `pinctrl`, `source`, `bc` *)

*) see [Installations](#installations)

### Installations

#### Raspberry Pi OS

Commands and Tools:

    sudo apt update
    sudo apt install zsh

#### AlmaLinux

Compiler Tools:

    sudo dnf update
    sudo dnf groupinstall "Development Tools"
    sudo dnf install cmake

Commands and Tools:

    sudo dnf update
    sudo dnf install bc
    sudo dnf install zsh
    git clone https://github.com/raspberrypi/utils.git
    cd utils/pinctrl/
    cmake .
    make
    sudo make install

### Example
The example script for a RC servo and LEDs control is located at:
- `./zsh/pwm/run.zsh`

This script uses functions defined in:
- `pwm.zsh` in the same directory.

Demo: https://youtu.be/Z8dT_J9DFvU

<div align="left">
      <a href="https://youtu.be/Z8dT_J9DFvU">
         <img src="https://img.youtube.com/vi/Z8dT_J9DFvU/0.jpg" style="width:500px;">
      </a>
</div>

#### Running the Script

Clone repository:

```bash
git clone https://github.com/simas2024/RPiTools.git
```

Navigate to the directory where the repository was cloned:
```bash
cd RPiTools
```
Start the script:

```bash
sudo ./zsh/pwm/run.zsh
```
or
```bash
sudo ./zsh/pwm/run.zsh &
```

Use the `CTRL-C` or `./zsh/pwm/stop.zsh` for stopping.

### Check

To verify that the function is correctly set.

```bash
pinctrl get 12,13,18,19

  12: a0    pd | lo // GPIO12 = PWM0_CHAN0
  13: a0    pd | lo // GPIO13 = PWM0_CHAN1
  18: a3    pd | lo // GPIO18 = PWM0_CHAN2
  19: a3    pd | lo // GPIO19 = PWM0_CHAN3
```
## References

### Datasheets

https://datasheets.raspberrypi.com/rp1/rp1-peripherals.pdf

### Forums and SO

https://forums.raspberrypi.com/viewtopic.php?t=366795

### Git Repositories

https://github.com/raspberrypi/rpi-firmware/tree/master/overlays#readme

https://github.com/raspberrypi/utils.git

https://github.com/Pioreactor/rpi_hardware_pwm

https://gist.github.com/Gadgetoid/b92ad3db06ff8c264eef2abf0e09d569

