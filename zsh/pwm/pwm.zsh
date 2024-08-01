#!/usr/bin/env zsh

typeset pwm_dir="/sys/class/pwm"

declare -A pwm_data

declare -A pwm_data_key_index=(
   ["chip"]="1"
   ["channel"]="2"
   ["frequency"]="3"
   ["chip_dir"]="4"
   ["channel_dir"]="5"
   ["export_path"]="6"
   ["enable_path"]="7"
   ["period_path"]="8"
   ["dutycycle_path"]="9" )

declare -A channel_pin_func=(
   ["0"]='12 a0'
   ["1"]='13 a0'
   ["2"]='18 a3'
   ["3"]='19 a3')

# args:  $1 : name $2 : value
function _start {
  local name=$1
  local value=$2
  local enable=$(_get $name enable_path)
  _change_duty_cycle $name $value
  echo 1 > "$enable"
}

# args: "name_1 chip_1 channel_1 frequency_1" ... "name_n chip_n channel_n frequency_n"
function _init {
  for tuples in "$@"; do
    IFS=' ' set -- $tuples
    tuple=$1
    local tupleA=("${(@s/ /)tuple}")
    local name=$tupleA[1]
    local chip=$tupleA[2]
    local channel=$tupleA[3]
    local frequency=$tupleA[4]
    local pwm_chip_dir=$pwm_dir/pwmchip$chip
    local pwm_channel_dir=$pwm_dir/pwmchip$chip/pwm$channel
    local pwm_export_path=$pwm_chip_dir/export
    local pwm_enable_path=$pwm_channel_dir/enable
    local pwn_period_path=$pwm_channel_dir/period
    local pwn_dutycycle_path=$pwm_channel_dir/duty_cycle
    pwm_data[$name]="$chip $channel $frequency $pwm_chip_dir $pwm_channel_dir $pwm_export_path $pwm_enable_path $pwn_period_path $pwn_dutycycle_path"
    # System checks
    [[ -d $pwm_chip_dir ]] || { echo "Need to add 'dtoverlay=pwm-2chan' to /boot/config.txt or /boot/firmware/config.txt and reboot"; return 1; }
    local pin_func=("${(@s/ /)channel_pin_func[$channel]}") 
    pinctrl set $pin_func[1] $pin_func[2]
    [[ -w "$pwm_export_path" ]] || { echo "Need write access to files in '${pwm_chip_dir}'"; return 1; }
    [[ -d $pwm_channel_dir ]] || { echo $channel > "$pwm_export_path" }
    # Set frequency
    _change_frequency $name
  done
}

function _get {                    
  local name=$1
  local key=$2  
  local index=$pwm_data_key_index[$key]
  local -a values=("${(@s/ /)pwm_data[$name]}")
  echo "${values[$index]}"
}

# args:  $1 : name $2 : duty cycle [%]  $3 : sleeptime [s]
function _duty_cycle { 
  local name=$1
  local value=$2
  local sleep_duration=$3
  _change_duty_cycle $name $value
  sleep $sleep_duration
}

# args:  $1 : name
function _stop {
  local name=$1
  local enable=$(_get $name enable_path)

  _change_duty_cycle $name 0
  echo 0 > "${enable}"
}

# args:  $1 : name $2 : duty cycle [%]
function _change_duty_cycle {
  local name=$1
  local duty_cycle=$2

  local frequency=$(_get $name frequency)
  local pwm_dutycycle_path=$(_get $name dutycycle_path)

  if (( $(echo "$duty_cycle < 0 || $duty_cycle > 100" | bc -l) )); then
    echo "Duty cycle must be between 0 and 100 (inclusive)." >&2
    return 1
  fi
  local period=$(echo "1 / $frequency * 1000 * 1000000" | bc -l)
  local dc=$(echo "$period * $duty_cycle / 100" | bc)
  echo $(printf "%.0f" $dc) > "${pwm_dutycycle_path}"
}

function _change_frequency {
  local name=$1

  local frequency=$(_get $name frequency)
  local pwn_period_path=$(_get $name period_path)

  if (( $(echo "$frequency < 0.1" | bc -l) )); then
    echo "Frequency can't be lower than 0.1 on the Rpi." >&2
    return 1
  fi

  local period=$(echo "1 / $frequency * 1000 * 1000000" | bc -l)
  echo $(printf "%.0f" $period) > "${pwn_period_path}"
}

# $1 : cmd (init, dc, start, stop) $2 : other arguments
function pwm { 
  local cmd=$1
  shift

  case $cmd in
    init)
      # Initialize
      _init $argv
      return 1
      ;;
    start)
      # Set enable = 1
      zparseopts -D -E -A args -- name:=args value:=args
      if [[ -z "${args[-name]}" || -z "${args[-value]}" ]]; then
        echo "Error: 'name' and 'value' are mandatory."
        return 1
      fi
      _start ${args[-name]} ${args[-value]}
      ;;
    stop)
      # Set enable = 0
      zparseopts -D -E -A args -- name:=args

      if [[ -z "${args[-name]}" ]]; then
        echo "Error: 'name' is mandatory."
        return 1
      fi
      _stop ${args[-name]}
      ;;
    dc)
      # Set Duty Cycle Value
      zparseopts -D -E -A args -- name:=args value:=args sleep:=args
      if [[ -z "${args[-name]}" || -z "${args[-value]}" ]]; then
        echo "Error: 'name' and 'value' are mandatory."
        return 1
      fi

      if [[ -z "${args[-sleep]}" ]]; then
        sleep_duration=0.0
      else
        sleep_duration="${args[-sleep]}"
      fi
      _duty_cycle  "${args[-name]}" "${args[-value]}" $sleep_duration
      ;;
    *)
      echo "Unsupported command: $cmd"
      return 1
      ;;
  esac
}