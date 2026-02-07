import Foundation
import Observation

@Observable
class ProgressStore {
    private static let userDefaultsKey = "clipProgressData"

    private var progressMap: [String: ClipProgress] = [:]

    init() {
        load()
    }

    func progress(for clipId: String) -> ClipProgress {
        progressMap[clipId] ?? ClipProgress()
    }

    func recordAnswer(clipId: String, isCorrect: Bool) {
        var p = progress(for: clipId)
        p.attempts += 1
        if isCorrect {
            p.corrects += 1
        }
        progressMap[clipId] = p
        save()
    }

    func recordPlay(clipId: String) {
        var p = progress(for: clipId)
        p.lastPlayedAt = Date()
        progressMap[clipId] = p
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(progressMap)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        } catch {
            print("ProgressStore: failed to save - \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey) else {
            return
        }
        do {
            progressMap = try JSONDecoder().decode([String: ClipProgress].self, from: data)
        } catch {
            print("ProgressStore: failed to load - \(error)")
        }
    }
}
