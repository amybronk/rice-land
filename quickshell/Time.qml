// Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Expose separate strings for time and date
    readonly property string timeString: Qt.formatDateTime(clock.date, "hh:mm:ss")
    readonly property string dateString: Qt.formatDateTime(clock.date, "dddd dd MMMM yyyy")
}