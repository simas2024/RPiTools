# RPiTools

A growing repository and a small collection of tools and scripts for the Raspberry Pi 5. It includes utilities for managing, and utilizing the GPIO (General Purpose Input/Output) pins.

- [Raspberry Pi 5 HW PWM Control](#raspberry-pi-5-hw-pwm-control)

## Platform

The script was tested and runs on Raspberry Pi OS and AlmaLinux.

### Raspberry Pi OS
             _,met$$$$$gg.           user@rspb01
          ,g$$$$$$$$$$$$$$$P.        -----------
        ,g$$P"         """Y$$.".     OS: Debian GNU/Linux bookworm 12.6 aarch64
       ,$$P'               `$$$.     Host: Raspberry Pi 5 Model B Rev 1.0
      ',$$P       ,ggs.     `$$b:    Kernel: Linux 6.6.40-v8-16k+
      `d$$'     ,$P"'   .    $$$     Uptime: 13 mins
       $$P      d$'     ,    $$$P    Packages: 1624 (dpkg), 1 (snap)
       $$:      $.   -    ,d$$'      Shell: bash 5.2.15
       $$;      Y$b._   _,d$P'       WM: Wayfire (X11)
       Y$$.    `.`"Y$$$$P"'          Cursor: Adwaita
       `$$b      "-.__               Terminal: /dev/pts/0
        `Y$$                         CPU: Cortex-A76 (4) @ 2.40 GHz
         `Y$$.                       Memory: 662.25 MiB / 7.86 GiB (8%)
           `$$b.                     Swap: 0 B / 199.98 MiB (0%)
             `Y$$b.                  Disk (/): 8.45 GiB / 915.32 GiB (1%) - ext4
                `"Y$b._              Local IP (eth0): 192.168.2.125/24
                   `"""              Locale: en_GB.UTF-8

### AlmaLinux

               'c:.                               user@rspb01
              lkkkx, ..       ..   ,cc,           -----------
              okkkk:ckkx'  .lxkkx.okkkkd          OS: AlmaLinux 9.4 aarch64
              .:llcokkx'  :kkkxkko:xkkd,          Host: Raspberry Pi 5 Model B Rev 1.0
            .xkkkkdood:  ;kx,  .lkxlll;           Kernel: Linux 6.6.31-20240529.v8.2.el9
             xkkx.       xk'     xkkkkk:          Uptime: 33 mins
             'xkx.       xd      .....,.          Shell: bash 5.1.8
            .. :xkl'     :c      ..''..           Cursor: Adwaita
          .dkx'  .:ldl:'. '  ':lollldkkxo;        Terminal: /dev/pts/0
        .''lkkko'                     ckkkx.      CPU: Cortex-A76 (4) @ 2.40 GHz
      'xkkkd:kkd.       ..  ;'        :kkxo.      Memory: 317.74 MiB / 7.76 GiB (4%)
      ,xkkkd;kk'      ,d;    ld.   ':dkd::cc,     Swap: 0 B / 100.00 MiB (0%)
       .,,.;xkko'.';lxo.      dx,  :kkk'xkkkkc    Disk (/): 5.18 GiB / 116.67 GiB (4%) - ext4
           'dkkkkkxo:.        ;kx  .kkk:;xkkd.    Local IP (eth0): 192.168.2.125/24 *
             .....   .;dk:.   lkk.  :;,           Locale: C.utf8
                   :kkkkkkkdoxkkx    
                    ,c,,;;;:xkkd.                
                      ;kkkkl...             
                      ;kkkkl    
                       ,od;      

      
## RPi and GPIO

                                                   +-----+--------+----------+--------+-----+
                                                   |     |  Name  | Physical |  Name  |     |
      ~ ---------------------------------          +-----+--------+----++----+--------+-----+
      ~                              o  o -------- |     |   3.3v |  1 || 2  |     5v |     |
      ~                              o  o          |   2 |  SDA.1 |  3 || 4  |     5V |     |
      ~                              o  o          |   3 |  SCL.1 |  5 || 6  |     0v |     |
      ~                              o  o          |   4 |   GPIO |  7 || 8  |  TxD.1 |  14 |
      ~                              o  o          |     |     0v |  9 || 10 |  RxD.1 |  15 |
      ~                              o  o          |  17 |   GPIO | 11 || 12 |   GPIO |  18 |
      ~                              o  o          |  27 |   GPIO | 13 || 14 |     0v |     |
      ~                              o  o          |  22 |   GPIO | 15 || 16 |   GPIO |  23 |
      ~          -------------       o  o          |     |   3.3v | 17 || 18 |   GPIO |  24 |
      ~         |             |      o  o          |  10 |   MOSI | 19 || 20 |     0v |     |
      ~         |   BCM2712   |      o  o          |   9 |   MISO | 21 || 22 |   GPIO |  25 |
      ~         |             |      o  o          |  11 |   SCLK | 23 || 24 |    CE0 |   8 |
      ~          -------------       o  o          |     |     0v | 25 || 26 |    CE1 |   7 |
      ~                              o  o          |   0 |  SDA.0 | 27 || 28 |  SCL.0 |   1 |
      ~                              o  o          |   5 |   GPIO | 29 || 30 |     0v |     |
      ~                              o  o          |   6 |   GPIO | 31 || 32 |   GPIO |  12 |
      ~                              o  o          |  13 |   GPIO | 33 || 34 |     0v |     |
      ~                              o  o          |  19 |   GPIO | 35 || 36 |   GPIO |  16 |
      ~                              o  o          |  26 |   GPIO | 37 || 38 |   GPIO |  20 |
      ~                              o  o -------- |     |     0v | 39 || 40 |   GPIO |  21 |
      ~                   -------        |         +-----+--------+----------+--------+-----+
      ~                  |       |       |
      ~                  |  RP1  |       |
      ~                  |       |       |
      ~                   -------        |
      ~     -----      -----      -----  |
      ~    | ETH |    | USB |    | USB | |
      ~    |     |    |     |    |     | |
      ~ ---       ----       ---      ----


## Raspberry Pi 5 HW PWM Control

A ZSH library and scripts for controlling hardware PWM on a Raspberry Pi 5 B using the `sysfs` interface.

- `./zsh/pwm/pwm.zsh` A ZSH library for controlling hardware PWM (Pulse Width Modulation) on a Raspberry Pi 5 B using the sysfs interface.
- `./zsh/pwm/run.zsh` A demo script that shows how to use the PWM ZSH library. It demonstrates the basic functions and use cases of PWM control.
- `./zsh/pwm/stop.zsh` A small script that can be used to stop a running `run.zsh` script in the background `./zsh/pwm/run.zsh &`.

### Features
- **ZSH Script for Hardware PWM**: Control PWM on Raspberry Pi 5 pins 12, 13, 18 and 19.
- **Demo Script**: Included is an example in zsh/pwm/run.zsh for controlling an RC servo and LEDs.

### Requirements
- `zsh` v5.8
- Add `dtoverlay=pwm-2chan` to `/boot/firmware/config.txt` (Raspberry Pi OS) or `/boot/config.txt` (AlmaLinux), respectively. So we can use GPIO 12, 13, 18 and 19 for PWM function. See [Overlay](#datasheet)

The library and script use some tools and builtin commands that come with Raspberry Pi OS and ZSH:
- `printf`, `echo`, `zparseopts`, `trap`, `shift`, `sleep`, `pinctrl`, `source`, `bc`

#### Set Up on Raspberry Pi OS

    sudo dnf install zsh

#### Set Up on AlmaLinux

Compiler:

    sudo yum groupinstall "Development Tools"
    sudo yum install cmake

Tools:

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
git clone git@git.simas.app:masc/RPiTools.git
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

### Datasheet

https://github.com/raspberrypi/rpi-firmware/tree/master/overlays#readme

https://datasheets.raspberrypi.com/rp1/rp1-peripherals.pdf

### Forum

https://forums.raspberrypi.com/viewtopic.php?t=366795

### Examples

https://github.com/Pioreactor/rpi_hardware_pwm

https://gist.github.com/Gadgetoid/b92ad3db06ff8c264eef2abf0e09d569

### Sources

https://github.com/raspberrypi/utils.git

