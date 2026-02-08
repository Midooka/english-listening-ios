import SwiftUI

struct PlayerView: View {
    let clips: [Clip]
    @State private var currentIndex: Int

    @Environment(ProgressStore.self) private var progressStore
    @State private var audioPlayer = AudioPlayer()
    @State private var showTranscript = false
    @State private var selectedAnswer: Int? = nil
    @State private var hasAnswered = false
    @State private var phase: LearningPhase = .listening
    @State private var showClipList = false

    private enum LearningPhase {
        case listening   // Audio + transcript + quiz
        case reviewing   // Explanation + word order button
        case wordOrder   // ScriptOrderTapView
    }

    private var clip: Clip { clips[currentIndex] }

    init(clips: [Clip], startIndex: Int) {
        self.clips = clips
        self._currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                audioPlayerSection

                if phase != .listening {
                    Button(action: resetQuiz) {
                        Label("Back to Quiz", systemImage: "arrow.uturn.backward")
                            .font(.subheadline)
                    }
                }

                switch phase {
                case .listening:
                    transcriptSection
                    quizSection

                case .reviewing:
                    explanationSection
                    Button(action: {
                        withAnimation { phase = .wordOrder }
                    }) {
                        Label("Next: Word Order", systemImage: "textformat.abc")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                case .wordOrder:
                    ScriptOrderTapView(transcript: clip.transcript, level: clip.level) {
                        // onComplete
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            if clips.count > 1 {
                navigationSection
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.bar)
            }
        }
        .navigationTitle(clip.id)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        progressStore.toggleBookmark(clipId: clip.id)
                    } label: {
                        Image(systemName: progressStore.isBookmarked(clipId: clip.id) ? "star.fill" : "star")
                            .foregroundStyle(progressStore.isBookmarked(clipId: clip.id) ? .yellow : .gray)
                    }

                    Button {
                        showClipList = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showClipList) {
            clipListSheet
        }
        .onAppear {
            progressStore.recordPlay(clipId: clip.id)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(clip.level)")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(levelColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())

                Text(clip.genre)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                let p = progressStore.progress(for: clip.id)
                if p.attempts > 0 {
                    Text("\(p.corrects)/\(p.attempts) correct")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var audioPlayerSection: some View {
        VStack(spacing: 16) {
            // Waveform icon
            Image(systemName: audioPlayer.isPlaying ? "waveform" : "waveform.circle")
                .font(.system(size: 60))
                .foregroundStyle(audioPlayer.isPlaying ? .blue : .gray)
                .symbolEffect(.variableColor, isActive: audioPlayer.isPlaying)

            // Play/Pause button
            HStack(spacing: 30) {
                Button(action: { audioPlayer.skip(seconds: -10) }) {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                .disabled(audioPlayer.currentClipId == nil)
                .opacity(audioPlayer.currentClipId == nil ? 0.3 : 1.0)

                Button(action: {
                    audioPlayer.togglePlayPause(clip: clip)
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }

                Button(action: { audioPlayer.skip(seconds: 10) }) {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                }
                .disabled(audioPlayer.currentClipId == nil)
                .opacity(audioPlayer.currentClipId == nil ? 0.3 : 1.0)
            }
            .foregroundStyle(.blue)

            // Seek bar
            HStack(spacing: 8) {
                Text(formatTime(audioPlayer.currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .trailing)

                Slider(
                    value: $audioPlayer.currentTime,
                    in: 0...max(audioPlayer.duration, 1)
                ) { editing in
                    audioPlayer.isSeeking = editing
                    if !editing {
                        audioPlayer.seek(to: audioPlayer.currentTime)
                    }
                }
                .tint(.blue)

                Text(formatTime(audioPlayer.duration))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .leading)
            }
            .padding(.horizontal)

            // Speed picker
            HStack {
                Text("Speed:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Speed", selection: $audioPlayer.rate) {
                    Text("0.7x").tag(Float(0.7))
                    Text("0.8x").tag(Float(0.8))
                    Text("0.9x").tag(Float(0.9))
                    Text("1.0x").tag(Float(1.0))
                    Text("1.2x").tag(Float(1.2))
                    Text("1.4x").tag(Float(1.4))
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // Error message
            if let errorMessage = audioPlayer.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    showTranscript.toggle()
                }
            }) {
                HStack {
                    Text(showTranscript ? "Hide Transcript" : "Show Transcript")
                        .font(.headline)
                    Spacer()
                    Image(systemName: showTranscript ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(.primary)
            }
            
            if showTranscript {
                Text(clip.transcript)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question")
                .font(.headline)
            
            Text(clip.question)
                .font(.body)
            
            VStack(spacing: 12) {
                ForEach(Array(clip.choices.enumerated()), id: \.offset) { index, choice in
                    ChoiceButton(
                        choice: choice,
                        index: index,
                        selectedAnswer: selectedAnswer,
                        correctAnswer: hasAnswered ? clip.answerIndex : nil,
                        action: {
                            selectAnswer(index)
                        }
                    )
                }
            }
            
            if hasAnswered {
                Button(action: resetQuiz) {
                    Text("Try Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explanation")
                .font(.headline)
            
            Text(clip.explanation)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGreen).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func selectAnswer(_ index: Int) {
        guard !hasAnswered else { return }

        selectedAnswer = index
        hasAnswered = true

        let isCorrect = index == clip.answerIndex
        progressStore.recordAnswer(clipId: clip.id, isCorrect: isCorrect)

        if isCorrect {
            withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                phase = .reviewing
            }
        }
    }
    
    private func resetQuiz() {
        withAnimation {
            selectedAnswer = nil
            hasAnswered = false
            phase = .listening
        }
    }
    
    private var navigationSection: some View {
        HStack(spacing: 10) {
            Button(action: goToPrevious) {
                Label("Prev", systemImage: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button(action: goToRandom) {
                Image(systemName: "shuffle")
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button(action: goToNext) {
                Label("Next", systemImage: "chevron.right")
                    .labelStyle(.titleAndIcon)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var clipListSheet: some View {
        NavigationStack {
            List {
                ForEach(Array(clips.enumerated()), id: \.element.id) { index, c in
                    Button {
                        showClipList = false
                        switchClip(to: index)
                    } label: {
                        HStack(spacing: 10) {
                            let p = progressStore.progress(for: c.id)
                            Group {
                                if p.attempts == 0 {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.gray)
                                } else if p.corrects > 0 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Image(systemName: "xmark.circle")
                                        .foregroundStyle(.orange)
                                }
                            }

                            Text(c.id)
                                .font(.body)
                                .fontWeight(index == currentIndex ? .bold : .regular)

                            Spacer()

                            Text("Lv\(c.level)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(levelColorFor(c.level))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .listRowBackground(index == currentIndex ? Color.blue.opacity(0.1) : nil)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Clips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showClipList = false
                    }
                }
            }
        }
    }

    private func levelColorFor(_ level: Int) -> Color {
        switch level {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }

    private func switchClip(to newIndex: Int) {
        audioPlayer.stop()
        withAnimation {
            selectedAnswer = nil
            hasAnswered = false
            phase = .listening
            showTranscript = false
            currentIndex = newIndex
        }
        progressStore.recordPlay(clipId: clips[newIndex].id)
    }

    private func goToPrevious() {
        let prevIndex = (currentIndex - 1 + clips.count) % clips.count
        switchClip(to: prevIndex)
    }

    private func goToNext() {
        let nextIndex = (currentIndex + 1) % clips.count
        switchClip(to: nextIndex)
    }

    private func goToRandom() {
        guard clips.count > 1 else { return }
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<clips.count)
        } while randomIndex == currentIndex
        switchClip(to: randomIndex)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
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

struct ChoiceButton: View {
    let choice: String
    let index: Int
    let selectedAnswer: Int?
    let correctAnswer: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(choice)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let correctAnswer = correctAnswer {
                    if index == correctAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if index == selectedAnswer {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(correctAnswer != nil)
    }
    
    private var backgroundColor: Color {
        if let correctAnswer = correctAnswer {
            if index == correctAnswer {
                return Color.green.opacity(0.1)
            } else if index == selectedAnswer {
                return Color.red.opacity(0.1)
            }
        }
        return Color(.systemBackground)
    }
    
    private var borderColor: Color {
        if let correctAnswer = correctAnswer {
            if index == correctAnswer {
                return .green
            } else if index == selectedAnswer {
                return .red
            }
        }
        return Color(.systemGray4)
    }
}
