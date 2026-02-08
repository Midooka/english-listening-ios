import Foundation
import AVFoundation
import Observation

@Observable
class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    
    var isPlaying: Bool = false
    var rate: Float = 1.0 {
        didSet {
            audioPlayer?.rate = rate
        }
    }
    var errorMessage: String?
    var currentClipId: String?
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var isSeeking: Bool = false
    private var positionTimer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }
    
    func play(clip: Clip) {
        let audioFileName = clip.audioId ?? clip.id

        // If already playing the same clip, just resume
        if currentClipId == clip.id, let player = audioPlayer {
            if !player.isPlaying {
                player.play()
                isPlaying = true
            }
            return
        }

        // Stop current playback if any
        stop()

        // Try to find audio file
        guard let audioURL = findAudioFile(audioFileName: audioFileName) else {
            errorMessage = "Audio file not found: \(audioFileName).m4a"
            return
        }
        
        // Load and play
        do {
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.delegate = self
            player.enableRate = true
            player.rate = rate
            player.prepareToPlay()
            player.play()
            
            audioPlayer = player
            currentClipId = clip.id
            duration = player.duration
            currentTime = player.currentTime
            isPlaying = true
            errorMessage = nil
            startPositionTimer()
        } catch {
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
            isPlaying = false
        }
    }
    
    func stop() {
        stopPositionTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentClipId = nil
        currentTime = 0
        duration = 0
    }

    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        let clamped = max(0, min(time, player.duration))
        player.currentTime = clamped
        currentTime = clamped
    }

    func skip(seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        seek(to: player.currentTime + seconds)
    }
    
    func togglePlayPause(clip: Clip) {
        if isPlaying && currentClipId == clip.id {
            pause()
        } else {
            play(clip: clip)
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopPositionTimer()
    }
    
    private func findAudioFile(audioFileName: String) -> URL? {
        // Try with subdirectory first (preferred)
        if let url = Bundle.main.url(forResource: audioFileName, withExtension: "m4a", subdirectory: "AudioSample") {
            return url
        }

        // Fallback: try without subdirectory
        if let url = Bundle.main.url(forResource: audioFileName, withExtension: "m4a") {
            return url
        }

        // Try Resources directory variants
        if let url = Bundle.main.url(forResource: audioFileName, withExtension: "m4a", subdirectory: "Resources/AudioSample") {
            return url
        }

        return nil
    }
    
    // MARK: - Position Timer

    private func startPositionTimer() {
        positionTimer?.invalidate()
        positionTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer, !self.isSeeking else { return }
            self.currentTime = player.currentTime
        }
    }

    private func stopPositionTimer() {
        positionTimer?.invalidate()
        positionTimer = nil
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPositionTimer()
        isPlaying = false
        currentClipId = nil
        currentTime = 0
        duration = 0
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopPositionTimer()
        errorMessage = "Decode error: \(error?.localizedDescription ?? "unknown")"
        isPlaying = false
        currentClipId = nil
    }
}
