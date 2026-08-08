pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

QtObject {
    id: audioController

    // Track and bind audio nodes using a property to satisfy Singleton constraints
    property PwObjectTracker objectTracker: PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    // Speaker Volume (0 - 100)
    readonly property int speakerVolume: {
        if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return 0;
        return Math.round(Pipewire.defaultAudioSink.audio.volume * 100);
    }

    // Speaker Mute status (true / false)
    readonly property bool speakerMuted: {
        if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return false;
        return Pipewire.defaultAudioSink.audio.muted;
    }

    // Microphone Volume (0 - 100)
    readonly property int micVolume: {
        if (!Pipewire.defaultAudioSource || !Pipewire.defaultAudioSource.audio) return 0;
        return Math.round(Pipewire.defaultAudioSource.audio.volume * 100);
    }

    // Microphone Mute status (true / false)
    readonly property bool micMuted: {
        if (!Pipewire.defaultAudioSource || !Pipewire.defaultAudioSource.audio) return false;
        return Pipewire.defaultAudioSource.audio.muted;
    }

    // Set speaker volume (accepts 0 - 100)
    function setSpeakerVolume(percentage) {
        if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return;
        let clampedValue = Math.max(0, Math.min(100, percentage));
        Pipewire.defaultAudioSink.audio.volume = clampedValue / 100.0;
    }

    // Toggle speaker mute state
    function toggleSpeakerMute() {
        if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio) return;
        Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
    }

    // Set microphone volume (accepts 0 - 100)
    function setMicVolume(percentage) {
        if (!Pipewire.defaultAudioSource || !Pipewire.defaultAudioSource.audio) return;
        let clampedValue = Math.max(0, Math.min(100, percentage));
        Pipewire.defaultAudioSource.audio.volume = clampedValue / 100.0;
    }

    // Toggle microphone mute state
    function toggleMicMute() {
        if (!Pipewire.defaultAudioSource || !Pipewire.defaultAudioSource.audio) return;
        Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted;
    }
}