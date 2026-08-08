pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property real brightness: 0.5 

    // --- READ FROM SYSTEM ---
    property Process readBrightness: Process {
        // brightnessctl -m outputs: amdgpu_bl1,backlight,120,50%,255
        // awk extracts the 4th column (50%)
        // tr deletes the % symbol so we just get "50"
        command: ["/bin/sh", "-c", "/usr/bin/brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseInt(text.trim());
                if (!isNaN(val)) {
                    root.brightness = val / 100.0;
                }
            }
        }
    }

    // --- WRITE TO SYSTEM ---
    property Process setBrightnessCmd: Process {}

    function setTarget(val) {
        root.brightness = val; 
        let percentInt = Math.round(val * 100);
        
        root.setBrightnessCmd.running = false;
        root.setBrightnessCmd.command = ["/usr/bin/brightnessctl", "set", percentInt + "%"];
        root.setBrightnessCmd.running = true;
        
        // Force an immediate read to sync state
        root.readBrightness.running = false;
        root.readBrightness.running = true;
    }

    // --- SYNC TIMING ---
    property Timer pollTimer: Timer {
        interval: 2000 
        running: true
        repeat: true
        onTriggered: {
            root.readBrightness.running = false;
            root.readBrightness.running = true;
        }
    }
}