import Foundation

struct ClipProgress: Codable {
    var attempts: Int = 0
    var corrects: Int = 0
    var lastPlayedAt: Date?

    var correctRate: Double {
        guard attempts > 0 else { return 0 }
        return Double(corrects) / Double(attempts)
    }
}
