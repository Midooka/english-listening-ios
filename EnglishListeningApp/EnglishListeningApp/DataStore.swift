import Foundation
import Observation

@Observable
class DataStore {
    var clips: [Clip] = []
    var errorMessage: String?
    
    init() {
        loadClips()
    }
    
    private func loadClips() {
        guard let url = Bundle.main.url(forResource: "clips", withExtension: "json") else {
            errorMessage = "clips.json not found in bundle"
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            clips = try JSONDecoder().decode([Clip].self, from: data)
        } catch {
            errorMessage = "Failed to load clips: \(error.localizedDescription)"
        }
    }
    
    func clips(filteredBy level: Int?, genre: String?, accent: String? = nil) -> [Clip] {
        var filtered = clips

        if let level = level {
            filtered = filtered.filter { $0.level == level }
        }

        if let genre = genre, genre != "All" {
            filtered = filtered.filter { $0.genre == genre }
        }

        if let accent = accent, accent != "All" {
            filtered = filtered.filter { $0.accent == accent }
        }

        return filtered
    }

    var allGenres: [String] {
        let genres = Set(clips.map { $0.genre })
        return ["All"] + genres.sorted()
    }

    var allAccents: [String] {
        let accents = Set(clips.map { $0.accent })
        return ["All"] + accents.sorted()
    }
}
