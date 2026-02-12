import Foundation
import Observation

@Observable
class ProgressStore {
    private static let userDefaultsKey = "clipProgressData"

    private var progressMap: [String: ClipProgress] = [:]

    /// コンテンツが変わったらリセットするためのバージョン。
    /// クリップ内容を差し替えたらインクリメントすること。
    private static let contentVersion = 2
    private static let contentVersionKey = "clipContentVersion"

    init() {
        migrateIfNeeded()
        load()
    }

    private func migrateIfNeeded() {
        let saved = UserDefaults.standard.integer(forKey: Self.contentVersionKey)
        if saved < Self.contentVersion {
            UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
            UserDefaults.standard.set(Self.contentVersion, forKey: Self.contentVersionKey)
        }
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

    func hasProgress(for clipId: String) -> Bool {
        (progressMap[clipId]?.attempts ?? 0) > 0
    }

    func hasCorrect(for clipId: String) -> Bool {
        (progressMap[clipId]?.corrects ?? 0) > 0
    }

    func recordPlay(clipId: String) {
        var p = progress(for: clipId)
        p.lastPlayedAt = Date()
        progressMap[clipId] = p
        save()
    }

    func toggleBookmark(clipId: String) {
        var p = progress(for: clipId)
        p.isBookmarked.toggle()
        progressMap[clipId] = p
        save()
    }

    func isBookmarked(clipId: String) -> Bool {
        progressMap[clipId]?.isBookmarked ?? false
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
