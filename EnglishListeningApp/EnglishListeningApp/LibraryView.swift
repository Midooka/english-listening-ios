import SwiftUI

private enum StatusFilter: String, CaseIterable {
    case all = "All"
    case new = "New"
    case correct = "Correct"
    case review = "Review"
    case bookmarked = "★"
}

struct LibraryView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(ProgressStore.self) private var progressStore
    @State private var selectedLevel: Int? = nil
    @State private var selectedGenre: String = "All"
    @State private var showCredits = false
    @State private var selectedStatus: StatusFilter = .all
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                filterSection
                
                // Clip List
                List {
                    ForEach(filteredClips) { clip in
                        NavigationLink(value: clip) {
                            ClipRow(clip: clip, progress: progressStore.progress(for: clip.id))
                        }
                    }

                    Section {
                        Button {
                            showCredits = true
                        } label: {
                            Text("Credits")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Library")
            .navigationDestination(for: Clip.self) { clip in
                let clips = filteredClips
                let index = clips.firstIndex(where: { $0.id == clip.id }) ?? 0
                PlayerView(clips: clips, startIndex: index)
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
            
            // Status Filter
            HStack {
                Text("Status:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Status", selection: $selectedStatus) {
                    ForEach(StatusFilter.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
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
        let clips = dataStore.clips(filteredBy: selectedLevel, genre: selectedGenre)
        switch selectedStatus {
        case .all:
            return clips
        case .new:
            return clips.filter { !progressStore.hasProgress(for: $0.id) }
        case .correct:
            return clips.filter { progressStore.hasCorrect(for: $0.id) }
        case .review:
            return clips.filter { progressStore.hasProgress(for: $0.id) && !progressStore.hasCorrect(for: $0.id) }
        case .bookmarked:
            return clips.filter { progressStore.isBookmarked(clipId: $0.id) }
        }
    }
}

struct ClipRow: View {
    let clip: Clip
    let progress: ClipProgress

    private var statusIcon: some View {
        Group {
            if progress.attempts == 0 {
                Image(systemName: "circle")
                    .foregroundStyle(.gray)
            } else if progress.corrects > 0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.orange)
            }
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            statusIcon
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(clip.id)
                        .font(.headline)
                Spacer()
                if progress.attempts > 0 {
                    Text("\(progress.corrects)/\(progress.attempts)")
                        .font(.caption)
                        .foregroundStyle(progress.corrects > 0 ? .green : .secondary)
                }
                Text("Level \(clip.level)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            HStack {
                Text(clip.genre)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let lastPlayed = progress.lastPlayedAt {
                    Spacer()
                    Text("Last: \(lastPlayed, format: .dateTime.month().day())")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(clip.transcript)
                .font(.callout)
                .lineLimit(2)
                .foregroundStyle(.primary)
            }
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
