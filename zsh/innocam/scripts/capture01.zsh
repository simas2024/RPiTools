#!/bin/zsh

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

mkdir -p captures

while true; do
    read -sk 1 key
    case $key in
        c)
            stop_preview
            echo "Foto wird aufgenommen..."
            rpicam-still --raw --output "captures/bild_$(date +%Y%m%d_%H%M%S).jpg" \
                --gain 1.0 --denoise cdn_off --ev 1.0 --awb daylight \
                --hdr single-exp --vflip --timeout 1 -n
            echo "Foto gespeichert."
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
