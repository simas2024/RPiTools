#!/usr/bin/env zsh

MYDIR=${0:a:h}

source ${MYDIR}/pwm.zsh

# Example : hitec HS81 MG
# Frequence = 50HZ
# Travel:      min |    mid |    max
# PW:        900μs | 1500μs | 2100μs
# ----------------------------------
# DC = PW * Frequence / 10000
# ----------------------------------
#             minv |   midv |   maxv
# Percent:    4.5% |   8.0% |  11.5%

# Raspberry 5:
# 
# Chip 2 (add dtoverlay=pwm-2chan to /boot/firmware/config.txt):
#       /sys/class/pwm/pwmchip2/ 
#
# Channel 0 1 2 3:
#       /sys/class/pwm/pwmchip2/pwm0
#       /sys/class/pwm/pwmchip2/pwm1
#       /sys/class/pwm/pwmchip2/pwm2 
#       /sys/class/pwm/pwmchip2/pwm3 
#
#                                                        +-----+--------+----------+--------+-----+
#                                                        |     |  Name  | Physical |  Name  |     |
# ~ ---------------------------------                    +-----+--------+----++----+--------+-----+
# ~                              o  o ------------------ |     |   3.3v |  1 || 2  |     5v |     |
# ~                              o  o                    |   2 |  SDA.1 |  3 || 4  |     5V |     |
# ~                              o  o                    |   3 |  SCL.1 |  5 || 6  |     0v |     |
# ~                              o  o                    |   4 |   GPIO |  7 || 8  |  TxD.1 |  14 |
# ~                              o  o                    |     |     0v |  9 || 10 |  RxD.1 |  15 |
# ~                              o  o < Channel 2        |  17 |   GPIO | 11 || 12 |   GPIO |  18 | 
# ~                              o  o                    |  27 |   GPIO | 13 || 14 |     0v |     |
# ~                              o  o                    |  22 |   GPIO | 15 || 16 |   GPIO |  23 |
# ~          -------------       o  o                    |     |   3.3v | 17 || 18 |   GPIO |  24 |
# ~         |             |      o  o                    |  10 |   MOSI | 19 || 20 |     0v |     |
# ~         |   BCM2712   |      o  o                    |   9 |   MISO | 21 || 22 |   GPIO |  25 |
# ~         |             |      o  o                    |  11 |   SCLK | 23 || 24 |    CE0 |   8 |
# ~          -------------       o  o                    |     |     0v | 25 || 26 |    CE1 |   7 |
# ~                              o  o                    |   0 |  SDA.0 | 27 || 28 |  SCL.0 |   1 |
# ~                              o  o                    |   5 |   GPIO | 29 || 30 |     0v |     |
# ~                              o  o < Channel 0        |   6 |   GPIO | 31 || 32 |   GPIO |  12 | 
# ~                  Channel 1 > o  o                    |  13 |   GPIO | 33 || 34 |     0v |     |
# ~                  Channel 3 > o  o                    |  19 |   GPIO | 35 || 36 |   GPIO |  16 |
# ~                              o  o                    |  26 |   GPIO | 37 || 38 |   GPIO |  20 |
# ~                              o  o ------------------ |     |     0v | 39 || 40 |   GPIO |  21 |
# ~                   -------        |                   +-----+--------+----------+--------+-----+
# ~                  |       |       |
# ~                  |  RP1  |       |
# ~                  |       |       |
# ~                   -------        |
# ~     -----      -----      -----  |
# ~    | ETH |    | USB |    | USB | |
# ~    |     |    |     |    |     | |
# ~ ---       ----       ---      ----
#
# pinctrl get 12,13,18,19
# 12: a0    pd | lo // GPIO12 = PWM0_CHAN0
# 13: a0    pd | lo // GPIO13 = PWM0_CHAN1
# 18: a3    pd | lo // GPIO18 = PWM0_CHAN2
# 19: a3    pd | lo // GPIO19 = PWM0_CHAN3

echo $$ > ${MYDIR}/run_zsh_pid

stopit() {
  pwm stop -name red
  pwm stop -name yellow
  pwm stop -name green
  pwm dc -name servo -value $midv -sleep $sleeptime
  pwm stop -name servo
}

trap 'echo "Stopping..."; stopit; rm ${MYDIR}/run_zsh_pid; exit 0' SIGUSR1
trap 'echo "Stopping..."; stopit; rm ${MYDIR}/run_zsh_pid; exit 0' SIGINT

echo $$ > ${MYDIR}/run_zsh_pid

sleeptime=0.2
minv=4.5
maxv=11.5
midv=$(echo "scale=1; ($maxv + $minv) / 2.0" | bc -l)
servo=1
green=3
yellow=0
red=2
# "name_1 chip_1 channel_1 frequency_1" ... "name_n chip_n channel_n frequency_n"
pwm init "red 2 2 100" "yellow 2 0 100" "green 2 3 100" "servo 2 1 50"
pwm start -name red -value 0
pwm start -name yellow -value 0
pwm start -name green -value 0
pwm start -name servo -value $midv

while true; do
  pwm dc -name red -value 80
  pwm dc -name servo -value $maxv -sleep $sleeptime
  pwm dc -name yellow -value 80
  pwm dc -name servo -value $midv -sleep $sleeptime
  pwm dc -name yellow -value 0
  pwm dc -name red -value 0
  pwm dc -name green -value 80
  pwm dc -name servo -value $minv -sleep $sleeptime
  pwm dc -name green -value 0
  pwm dc -name yellow -value 80
  pwm dc -name servo -value $midv -sleep $sleeptime
  pwm dc -name yellow -value 0
done