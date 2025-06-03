Done with ChatGPT 4o

⸻

📸 🎥 Anwendung

Skript unter SSH und mit ZSH auf dem RPi starten

Live-Stream mit rpicam-vid (UDP) starten

Vorschau auf den Client streamen und dort mit ffplay oder VLC ansehen

Beim Drücken von c ein Foto mit rpicam-still macht und lokal auf dem Pi speichern

⸻

💻 Plattform

Server: RPi5 Raspberry Pi: Debian GNU/Linux bookworm 12.11 aarch64 OS 6.12.25+rpt-rpi-2712
Client: macoOS 15.5, ssh, zsh 

⸻

Skript: [capture01.zsh](scripts/capture01.zsh)



```zsh
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
```

⸻

🔧 Anleitung

1️⃣ Starte auf dem Server:

```zsh
ffplay udp://@:5000
```

2️⃣ Starte auf dem RPi (per SSH):

```zsh
./capture01.zsh
```

3️⃣ Drücke:
	•	c ➔ Foto wird aufgenommen (auf dem Pi gespeichert).
	•	s ➔ Stream wird gestoppt und Skript beendet.

⸻

🚦 Hinweis
	•	IP-Adresse anpassen: 192.168.2.101 im Skript muss die IP des Client sein.

⸻
