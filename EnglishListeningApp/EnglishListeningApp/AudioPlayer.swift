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
            isPlaying = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
            isPlaying = false
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentClipId = nil
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
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentClipId = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        errorMessage = "Decode error: \(error?.localizedDescription ?? "unknown")"
        isPlaying = false
        currentClipId = nil
    }
}
