#!/bin/zsh

# Skriptverzeichnis bestimmen (auch bei Symlink-Aufruf)
SCRIPT_PATH=${(%):-%N}
SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$SCRIPT_PATH")")" && pwd)

# Beispiel: Bilder werden hier gespeichert
CAPTURE_DIR="$SCRIPT_DIR/captures"

# Verzeichnis anlegen, falls es nicht existiert
mkdir -p "$CAPTURE_DIR"

function stop_preview() {
    echo "Vorschau stoppen..."
    kill $PREVIEW_PID 2>/dev/null
    wait $PREVIEW_PID 2>/dev/null
    sleep 0.5  # kleine Pause zur Sicherheit
}

function start_preview() {
    rpicam-vid --width 1920 --height 1080 --framerate 30 \
        --low-latency on --denoise cdn_off --awb daylight \
        --saturation 0.0 --hdr single-exp --timeout 0 --vflip \
        -o udp://192.168.2.101:5000 > /dev/null 2>&1 &
    PREVIEW_PID=$!
}

start_preview
echo "Stream läuft... (Taste 'c' = Foto machen, 's' = stoppen und beenden)"

while true; do
    read -sk 1 key
    case $key in
        c)
            stop_preview
            echo "Foto wird aufgenommen..."
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            rpicam-still --raw  --output "$CAPTURE_DIR/bild_${TIMESTAMP}.jpg" --hdr single-exp --vflip --timeout 1000 -n
            echo "Foto gespeichert: $CAPTURE_DIR/bild_${TIMESTAMP}.jpg" 
            rpicam-still --output "$CAPTURE_DIR/bild_bw_${TIMESTAMP}.jpg" --saturation 0.0 --hdr single-exp --vflip --timeout 1000 -n
            echo "Foto gespeichert: $CAPTURE_DIR/bild_bw_${TIMESTAMP}.jpg"
            echo "Vorschau wird neu gestartet..."
            start_preview
            ;;
        s)
            stop_preview
            echo "Beende Skript."
            break
            ;;
    esac
done