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
    
    func clips(filteredBy level: Int?, genre: String?) -> [Clip] {
        var filtered = clips
        
        if let level = level {
            filtered = filtered.filter { $0.level == level }
        }
        
        if let genre = genre, genre != "All" {
            filtered = filtered.filter { $0.genre == genre }
        }
        
        return filtered
    }
    
    var allGenres: [String] {
        let genres = Set(clips.map { $0.genre })
        return ["All"] + genres.sorted()
    }
}
