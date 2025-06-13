#!/usr/bin/env zsh

# --------------------------------------------------------------
# This script was developed with the assistance of ChatGPT-4o 
# with minor changes from the user.
# The ideas and requirements originated from the user.
# --------------------------------------------------------------

# Skriptverzeichnis bestimmen (auch bei Symlink-Aufruf)
SCRIPT_PATH=${(%):-%N}
SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$SCRIPT_PATH")")" && pwd)

# Beispiel: Bilder werden hier gespeichert
CAPTURE_DIR="$SCRIPT_DIR/captures"
mkdir -p "$CAPTURE_DIR"

# Default-Werte
WIDTH=1920
HEIGHT=1080
FRAMERATE=30
STREAMER="rpicam-vid"
CLIENTIP="127.0.0.1"
CLIENTPORT="5000"
GST_CMD="/usr/bin/gst-launch-1.0"

# Optionen parsen mit zparseopts
zparseopts -E -D -F - -help=opt_help h=opt_help -gst=opt_gst -rpicam=opt_rpicam \
    -width:=opt_width -height:=opt_height -framerate:=opt_framerate \
    -clientip:=opt_clientip -clientport:=opt_clientport -gstver:=opt_gstver

if [[ -n "$opt_help" ]]; then
    echo "
Usage: $0 [OPTIONS]

Options:
  --gst                 Use GStreamer for streaming instead of rpicam-vid
  --rpicam              Use rpicam-vid for streaming (default)
  --width <value>       Set video width (default: 1920, only for rpicam-vid)
  --height <value>      Set video height (default: 1080, only for rpicam-vid)
  --framerate <value>   Set video framerate (default: 30, only for rpicam-vid)
  --clientip <value>    Set client IP address (default: 127.0.0.1)
  --clientport <value>  Set client port (default: 5000)
  --gstver <path>       Path to gst-launch executable (default: /usr/bin/gst-launch-1.0)
  -h, --help            Show this help message and exit

Note:
  - The options --width, --height, and --framerate are only effective with the rpicam-vid streamer.
  - When using GStreamer (--gst), these options are ignored.
  - If GStreamer (--gst) is used, --gstver can be specified; otherwise, it is ignored.

Example:
  $0 --rpicam --width 1280 --height 720 --framerate 25
  $0 --gst --clientip 192.168.0.100 --clientport 6000
  $0 --gst --gstver /opt/gstreamer/1.26.2/bin/gst-launch-1.0 --clientip 192.168.2.120 --clientport 5000
"
    exit 0
fi

[[ -n "$opt_gst" ]] && STREAMER="gst"
[[ -n "$opt_rpicam" ]] && STREAMER="rpicam-vid"

# Nur für rpicam-vid übernehmen:
if [[ "$STREAMER" == "rpicam-vid" ]]; then
    [[ -n "$opt_width" ]] && WIDTH="${opt_width[2]}"
    [[ -n "$opt_height" ]] && HEIGHT="${opt_height[2]}"
    [[ -n "$opt_framerate" ]] && FRAMERATE="${opt_framerate[2]}"
else
    echo "Hinweis: Die Optionen --width, --height und --framerate werden für GStreamer ignoriert."
fi

[[ -n "$opt_clientip" ]] && CLIENTIP="${opt_clientip[2]}"
[[ -n "$opt_clientport" ]] && CLIENTPORT="${opt_clientport[2]}"
[[ -n "$opt_gstver" ]] && GST_CMD="${opt_gstver[2]}"


function stop_preview() {
    echo "Stopping preview..."  
    kill $PREVIEW_PID 2>/dev/null
    wait $PREVIEW_PID 2>/dev/null
    sleep 0.5
}

function start_preview() {
    if [[ -z $($GST_CMD --version 2>/dev/null | head -n 1) ]]; then
        stop_preview
        echo "$GST_CMD not found. Exiting script."
        exit 1
    fi

    echo "Starting preview ($STREAMER) at ${WIDTH}x${HEIGHT} @ ${FRAMERATE}fps..."
    [[ "$STREAMER" == "gst" ]] && echo "Using $GST_CMD ($($GST_CMD --version | head -n 1))"

    if [[ "$STREAMER" == "rpicam-vid" ]]; then
        rpicam-vid --width $WIDTH --height $HEIGHT --framerate $FRAMERATE \
        --low-latency on --inline --flush --denoise cdn_off \
        --awb daylight --saturation 0.0 --timeout 0 --vflip -n \
        -o udp://${CLIENTIP}:${CLIENTPORT} > /dev/null 2>&1 &
        PREVIEW_PID=$!
    elif [[ "$STREAMER" == "gst" ]]; then
        "$GST_CMD" libcamerasrc af-mode=continuous ! \
            video/x-raw,width=$WIDTH,height=$HEIGHT,framerate=${FRAMERATE}/1 ! \
            queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 leaky=downstream ! \
            x264enc tune=zerolatency speed-preset=ultrafast key-int-max=30 insert-vui=1 ! \
            h264parse ! \
            rtph264pay config-interval=1 pt=96 ! \
            udpsink host=$CLIENTIP port=$CLIENTPORT > /dev/null 2>&1 &
        PREVIEW_PID=$!
    fi
}

start_preview
echo "Stream running... (Press 'c' = capture, 's' = stop and exit)"

while true; do
    read -sk 1 key
    case $key in
        c)
            stop_preview
            echo "Capturing image..."
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            rpicam-still --raw --output "$CAPTURE_DIR/image_${TIMESTAMP}.jpg" --hdr single-exp --vflip --timeout 1000 -n
            echo "Image saved: $CAPTURE_DIR/image_${TIMESTAMP}.jpg"
            rpicam-still --output "$CAPTURE_DIR/image_bw_${TIMESTAMP}.jpg" --saturation 0.0 --hdr single-exp --vflip --timeout 1000 -n
            echo "Image saved: $CAPTURE_DIR/image_bw_${TIMESTAMP}.jpg"
            echo "Restarting preview..."
            start_preview
            ;;
        s)
            stop_preview
            echo "Exiting script."
            break
            ;;
    esac
done
