# RPiTools

- Raspberry Pi 5 HW PWM Control

## Raspberry Pi 5 HW PWM Control

In `./zsh/pwm` zsh scripts for controlling hardware PWM on a Raspberry Pi 5 B using the `sysfs` interface.

### Features
- **ZSH Script for Hardware PWM**: Control PWM on Raspberry Pi 5 pins 12, 13, and 18.
- **Servo Control Example**: Included example in `zsh/pwm/run.zsh` for controlling a servo motor.

### Platform (tested)
- Raspberry Pi 5 Model B
- Linux 6.6.40-v8-16k+
- Raspberry Pi OS


                                                             +-----+--------+----------+--------+-----+
                                                             |     |  Name  | Physical |  Name  |     |
      ~ ---------------------------------                    +-----+--------+----++----+--------+-----+
      ~                              o  o ------------------ |     |   3.3v |  1 || 2  |     5v |     |
      ~                              o  o                    |   2 |  SDA.1 |  3 || 4  |     5V |     |
      ~                              o  o                    |   3 |  SCL.1 |  5 || 6  |     0v |     |
      ~                              o  o                    |   4 |   GPIO |  7 || 8  |  TxD.1 |  14 |
      ~                              o  o                    |     |     0v |  9 || 10 |  RxD.1 |  15 |
      ~                              o  o < Channel 2        |  17 |   GPIO | 11 || 12 |   GPIO |  18 |
      ~                              o  o                    |  27 |   GPIO | 13 || 14 |     0v |     |
      ~                              o  o                    |  22 |   GPIO | 15 || 16 |   GPIO |  23 |
      ~          -------------       o  o                    |     |   3.3v | 17 || 18 |   GPIO |  24 |
      ~         |             |      o  o                    |  10 |   MOSI | 19 || 20 |     0v |     |
      ~         |   BCM2712   |      o  o                    |   9 |   MISO | 21 || 22 |   GPIO |  25 |
      ~         |             |      o  o                    |  11 |   SCLK | 23 || 24 |    CE0 |   8 |
      ~          -------------       o  o                    |     |     0v | 25 || 26 |    CE1 |   7 |
      ~                              o  o                    |   0 |  SDA.0 | 27 || 28 |  SCL.0 |   1 |
      ~                              o  o                    |   5 |   GPIO | 29 || 30 |     0v |     |
      ~                              o  o < Channel 0        |   6 |   GPIO | 31 || 32 |   GPIO |  12 |
      ~                  Channel 1 > o  o                    |  13 |   GPIO | 33 || 34 |     0v |     |
      ~                  Channel 3 > o  o                    |  19 |   GPIO | 35 || 36 |   GPIO |  16 |
      ~                              o  o                    |  26 |   GPIO | 37 || 38 |   GPIO |  20 |
      ~                              o  o ------------------ |     |     0v | 39 || 40 |   GPIO |  21 |
      ~                   -------        |                   +-----+--------+----------+--------+-----+
      ~                  |       |       |
      ~                  |  RP1  |       |
      ~                  |       |       |
      ~                   -------        |
      ~     -----      -----      -----  |
      ~    | ETH |    | USB |    | USB | |
      ~    |     |    |     |    |     | |
      ~ ---       ----       ---      ----

### Requirements
- `zsh` v5.9
- Add `dtoverlay=pwm-2chan` to `/boot/firmware/config.txt`

The script uses some tools and commands that come with Raspberry Pi OS or ZSH::
- `printf`, `echo`, `zparseopts`, `trap`, `shift`, `sleep`, `pinctrl`, `source`, `bc`

### Example
The example script for a servo motor control is located at:
- `./zsh/pwm/run.zsh`

This script uses functions defined in:
- `pwm.zsh` in the same directory.

Demo: https://youtu.be/KVOtXnceXw4

<div align="left">
      <a href="https://youtu.be/KVOtXnceXw4">
         <img src="https://img.youtube.com/vi/KVOtXnceXw4/0.jpg" style="width:400px;">
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

Set the parameters correctly and connect the servo motor to the configured PIN:

```bash
sleeptime=0.5
minv=4.5
maxv=10.5
channel=1
```
 Start the script:

```bash
sudo .zsh/pwm/run.zsh
```
or
```bash
sudo .zsh/pwm/run.zsh &
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

https://forums.raspberrypi.com/viewtopic.php?t=366795

https://github.com/Pioreactor/rpi_hardware_pwm

https://gist.github.com/Gadgetoid/b92ad3db06ff8c264eef2abf0e09d569

https://datasheets.raspberrypi.com/rp1/rp1-peripherals.pdf