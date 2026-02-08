import Foundation

struct ClipProgress: Codable {
    var attempts: Int = 0
    var corrects: Int = 0
    var lastPlayedAt: Date?
    var isBookmarked: Bool = false

    var correctRate: Double {
        guard attempts > 0 else { return 0 }
        return Double(corrects) / Double(attempts)
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attempts = try container.decodeIfPresent(Int.self, forKey: .attempts) ?? 0
        corrects = try container.decodeIfPresent(Int.self, forKey: .corrects) ?? 0
        lastPlayedAt = try container.decodeIfPresent(Date.self, forKey: .lastPlayedAt)
        isBookmarked = try container.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
    }
}
