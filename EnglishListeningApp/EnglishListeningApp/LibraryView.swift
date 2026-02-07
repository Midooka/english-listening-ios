import SwiftUI

struct LibraryView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var selectedLevel: Int? = nil
    @State private var selectedGenre: String = "All"
    @State private var showCredits = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                filterSection
                
                // Clip List
                List {
                    ForEach(filteredClips) { clip in
                        NavigationLink(value: clip) {
                            ClipRow(clip: clip)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Library")
            .navigationDestination(for: Clip.self) { clip in
                PlayerView(clip: clip)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Credits") {
                        showCredits = true
                    }
                }
            }
            .sheet(isPresented: $showCredits) {
                CreditsView()
            }
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Level Filter
            HStack {
                Text("Level:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Picker("Level", selection: $selectedLevel) {
                    Text("All").tag(nil as Int?)
                    Text("1").tag(1 as Int?)
                    Text("2").tag(2 as Int?)
                    Text("3").tag(3 as Int?)
                }
                .pickerStyle(.segmented)
            }
            
            // Genre Filter
            HStack {
                Text("Genre:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Picker("Genre", selection: $selectedGenre) {
                    ForEach(dataStore.allGenres, id: \.self) { genre in
                        Text(genre).tag(genre)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var filteredClips: [Clip] {
        dataStore.clips(filteredBy: selectedLevel, genre: selectedGenre)
    }
}

struct ClipRow: View {
    let clip: Clip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(clip.id)
                    .font(.headline)
                Spacer()
                Text("Level \(clip.level)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            
            Text(clip.genre)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(clip.transcript)
                .font(.callout)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
    
    private var levelColor: Color {
        switch clip.level {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
}
