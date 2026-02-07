import Foundation

struct Clip: Codable, Identifiable, Hashable {
    let id: String
    let audioId: String?  // LibriSpeech audio ID (e.g., "2412-153954-0019")
    let level: Int
    let genre: String
    let transcript: String
    let question: String
    let choices: [String]
    let answerIndex: Int
    let explanation: String
}
