// Media/MprisController.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // --- State Properties ---
    // Extract the actual array of players using .values
    property var availablePlayers: Mpris.players.values ?? []
    
    // Reference to manually selected player, if any
    property var manualPlayer: null
    
    // The currently active player mapped to the UI
    property MprisPlayer currentPlayer: _resolveActive()

    property real visualProgress: 0

    // Timer that forces the UI to update smoothly
    Timer {
        id: uiTickTimer
        interval: 100 // Update 10 times per second (very smooth)
        running: root.isPlaying // Only run when music is playing
        repeat: true
        onTriggered: {
            if (currentPlayer && currentPlayer.length > 0) {
                visualProgress = currentPlayer.position / currentPlayer.length
            }
        }
    }

    // --- Dynamic Connections ---
    // Keep the player list updated when applications open or close
    Connections {
        target: Mpris.players

        function onObjectInsertedPost() {
            root.availablePlayers = Mpris.players.values
            root.currentPlayer = root._resolveActive()
        }

        function onObjectRemovedPost() {
            root.availablePlayers = Mpris.players.values
            
            // Check if the manually selected player was closed
            let manualStillExists = false
            for (let i = 0; i < root.availablePlayers.length; i++) {
                if (root.manualPlayer && root.availablePlayers[i].identity === root.manualPlayer.identity) {
                    manualStillExists = true
                    break
                }
            }
            if (!manualStillExists) {
                root.manualPlayer = null
            }
            
            root.currentPlayer = root._resolveActive()
        }

        function onValuesChanged() {
            root.availablePlayers = Mpris.players.values
            root.currentPlayer = root._resolveActive()
        }
    }

    // --- Active Player Resolution ---
    function _resolveActive(): MprisPlayer {
        const list = root.availablePlayers
        if (!list || list.length === 0) return null

        // 1. Manual override takes priority
        if (root.manualPlayer !== null) {
            return root.manualPlayer
        }

        // 2. Check for any currently playing player
        for (let i = 0; i < list.length; i++) {
            if (list[i].playbackState === MprisPlaybackState.Playing) {
                return list[i]
            }
        }

        // 3. Fallback to the first available player
        return list[0]
    }

    // --- Player Management Methods ---
    function selectPlayerByName(identityName) {
        const list = root.availablePlayers
        for (let i = 0; i < list.length; i++) {
            if (list[i].identity === identityName) {
                root.manualPlayer = list[i]
                root.currentPlayer = root._resolveActive()
                return
            }
        }
        root.manualPlayer = null
        root.currentPlayer = root._resolveActive()
    }

    function clearPlayerSelection() {
        root.manualPlayer = null
        root.currentPlayer = root._resolveActive()
    }

    // --- Media Information ---
    readonly property string trackTitle: currentPlayer ? currentPlayer.trackTitle : "No Media"
    readonly property string trackArtist: currentPlayer ? currentPlayer.trackArtist : "Unknown Artist"
    readonly property url trackArtUrl: currentPlayer ? currentPlayer.trackArtUrl : ""
    
    // --- Playback State ---
    readonly property bool isPlaying: currentPlayer ? currentPlayer.playbackState === MprisPlaybackState.Playing : false
    readonly property real position: currentPlayer ? currentPlayer.position : 0
    readonly property real length: currentPlayer ? currentPlayer.length : 1
    readonly property real progressPercentage: length > 0 ? Math.min(1.0, Math.max(0.0, position / length)) : 0

    // Combined seek function compatible with MPRIS
    function seekToRatio(ratio) {
        if (!currentPlayer || currentPlayer.length <= 0) return;
        currentPlayer.position = ratio * currentPlayer.length;
    }

    // --- Volume Management ---
    property real volume: currentPlayer ? currentPlayer.volume : 0.0
    onVolumeChanged: {
        if (currentPlayer && currentPlayer.volume !== volume) {
            currentPlayer.volume = volume
        }
    }

    // --- Shuffle & Repeat State ---
    property bool shuffle: currentPlayer ? currentPlayer.shuffle : false
    onShuffleChanged: {
        if (currentPlayer && currentPlayer.shuffle !== shuffle) {
            currentPlayer.shuffle = shuffle
        }
    }
    
    // CHANGED: loopStatus -> loopState
    readonly property int loopState: currentPlayer ? currentPlayer.loopState : MprisLoopState.None

    // --- Playback Controls ---
    function playPause() { 
        if (currentPlayer) currentPlayer.togglePlaying() 
    }
    
    function next() { 
        if (currentPlayer && currentPlayer.canGoNext) currentPlayer.next() 
    }
    
    function previous() { 
        if (currentPlayer && currentPlayer.canGoPrevious) currentPlayer.previous() 
    }

    // --- State Toggles ---
    function toggleShuffle() {
        if (currentPlayer) currentPlayer.shuffle = !currentPlayer.shuffle
    }

    function toggleLoop() {
        if (!currentPlayer) return
        
        // CHANGED: loopStatus -> loopState
        if (currentPlayer.loopState === MprisLoopState.None) {
            currentPlayer.loopState = MprisLoopState.Playlist
        } else if (currentPlayer.loopState === MprisLoopState.Playlist) {
            currentPlayer.loopState = MprisLoopState.Track
        } else {
            currentPlayer.loopState = MprisLoopState.None
        }
    }
}