import Foundation

struct Clip: Codable, Identifiable, Hashable {
    let id: String
    let level: Int
    let genre: String
    let transcript: String
    let question: String
    let choices: [String]
    let answerIndex: Int
    let explanation: String
}
