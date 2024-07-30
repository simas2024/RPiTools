#!/usr/bin/env zsh

typeset pwm_dir="/sys/class/pwm"
typeset pwm_chip_dir="${pwm_dir}"
typeset pwm_channel_dir="${pwm_dir}"
typeset -F old_duty_cycle=0.0
typeset -F freq=0.0
typeset self_channel=0
typeset self_chip=0

function _start {
  _change_duty_cycle $1
  echo 1 > "${pwm_channel_dir}/enable"
}

function _init { # $1 : frequence [hz]
  # System checks
  [[ -d $pwm_chip_dir ]] || { echo "Need to add 'dtoverlay=pwm-2chan' to /boot/config.txt or /boot/firmware/config.txt and reboot"; return 1; }

  # Select function according to Table 4, ‘GPIO function selection’, in the RP1 Peripherals datasheet: https://datasheets.raspberrypi.com/rp1/rp1-peripherals.pdf)
  case $self_channel in
    "0")
      pin="12"
      func="a0"
      ;;
    "1")
      pin="13"
      func="a0"
      ;;
    "2")
      pin="18"
      func="a3"
      ;;
    "3")
      pin="19"
      func="a3"
      ;;
  esac

  pinctrl set $pin $func

  [[ -w "${pwm_chip_dir}/export" ]] || { echo "Need write access to files in '${pwm_chip_dir}'"; return 1; }
  [[ -d $pwm_channel_dir ]] || { echo $self_channel > "${pwm_chip_dir}/export" }

  # Set frequency
  while true; do
    _change_frequency $1 && break
    sleep 1
  done
}

function _duty_cycle { # $1 : duty cycle [%]  $2 : sleeptime [s]
  local value=$1
  local sleep_duration=$2
  _change_duty_cycle $value
  sleep $sleep_duration
}

function _stop {
  _change_duty_cycle 0
  echo > 0 "${pwm_channel_dir}/enable"
}

function _change_duty_cycle {
  local duty_cycle=$1

  if (( $(echo "$duty_cycle < 0 || $duty_cycle > 100" | bc -l) )); then
    echo "Duty cycle must be between 0 and 100 (inclusive)." >&2
    return 1
  fi
  local per=$(echo "1 / $freq * 1000 * 1000000" | bc -l)
  local dc=$(echo "$per * $duty_cycle / 100" | bc)
  echo $(printf "%.0f" $dc) > "${pwm_channel_dir}/duty_cycle"
  old_duty_cycle=$dc
}

function _change_frequency {
  local hz=$1

  if (( $(echo "$hz < 0.1" | bc -l) )); then
    echo "Frequency can't be lower than 0.1 on the Rpi." >&2
    return 1
  fi

  freq=$hz

  local original_duty_cycle=$old_duty_cycle
  if (( $(echo "$old_duty_cycle > 0" | bc -l) )); then
    _change_duty_cycle 0
  fi

  local per=$(echo "1 / $freq * 1000 * 1000000" | bc -l)
  echo $(printf "%.0f" $per) > "${pwm_channel_dir}/period"

  _change_duty_cycle $original_duty_cycle
}

function pwm { # $1 : cmd (init, dc, start, stop) $2 : 'args'
  local cmd=$1
  shift

  zparseopts -D -E -A args -- channel:=args freq:=args chip:=args value:=args sleep:=args

  if [[ -z "${args[-channel]}" || -z "${args[-chip]}" ]]; then
    echo "Error: 'channel' and 'chip' are mandatory."
    return 1
  fi

  self_channel=$args[-channel]
  self_chip=$args[-chip]
  pwm_chip_dir="${pwm_dir}/pwmchip$self_chip"
  pwm_channel_dir="${pwm_chip_dir}/pwm$self_channel"

  case $cmd in
    init)
      # Initialize
      if [[ -z "${args[-freq]}" ]]; then
        echo "Error: 'freq' is mandatory."
        return 1
      fi
      _init ${args[-freq]}
      ;;
    start)
      # Set enable = 1
      if [[ -z "${args[-value]}" ]]; then
        echo "Error: 'value' is mandatory."
        return 1
      fi
      _start ${args[-value]}
      ;;
    stop)
      # Set enable = 0
      _stop
      ;;
    dc)
      # Set Duty Cycle Value
      if [[ -z "${args[-value]}" ]]; then
        echo "Error: 'value' is mandatory."
        return 1
      fi

      if [[ -z "${args[-sleep]}" ]]; then
        sleep_duration=1.0
      else
        sleep_duration="${args[-sleep]}"
      fi

      _duty_cycle "${args[-value]}" $sleep_duration
      ;;
    *)
      echo "Unsupported command: $cmd"
      return 1
      ;;
  esac
}

trap 'echo "Stopping..."; pwm stop -channel ${self_channel} -chip ${self_chip}; rm ${MYDIR}/run_zsh_pid; exit 0' SIGUSR1
trap 'echo "Stopping..."; pwm stop -channel ${self_channel} -chip ${self_chip}; rm ${MYDIR}/run_zsh_pid; exit 0' SIGINT

echo $$ > ${MYDIR}/run_zsh_pid