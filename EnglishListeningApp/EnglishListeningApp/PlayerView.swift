import SwiftUI

struct PlayerView: View {
    let clip: Clip
    
    @State private var showTranscript = false
    @State private var selectedAnswer: Int? = nil
    @State private var hasAnswered = false
    @State private var showExplanation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Clip Info
                headerSection
                
                // Audio Player (Placeholder)
                audioPlayerSection
                
                // Transcript Toggle
                transcriptSection
                
                // Quiz Section
                quizSection
                
                // Explanation (shown after answering)
                if showExplanation {
                    explanationSection
                }
            }
            .padding()
        }
        .navigationTitle(clip.id)
        .navigationBarTitleDisplayMode(.inline)
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
            }
        }
    }
    
    private var audioPlayerSection: some View {
        VStack(spacing: 16) {
            // Placeholder for audio player
            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            HStack(spacing: 30) {
                Button(action: {}) {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                
                Button(action: {}) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: {}) {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                }
            }
            .foregroundStyle(.blue)
            
            Text("Audio playback not yet implemented")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        
        withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
            showExplanation = true
        }
    }
    
    private func resetQuiz() {
        withAnimation {
            selectedAnswer = nil
            hasAnswered = false
            showExplanation = false
        }
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
