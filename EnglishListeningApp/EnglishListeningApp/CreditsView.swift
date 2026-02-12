import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Credits")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Audio")
                            .font(.headline)

                        Text("Generated with macOS Text-to-Speech")
                            .font(.body)

                        Text("8 voices across 6 accent varieties: American, British, Australian, Irish, Indian, and South African.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Content")
                            .font(.headline)

                        Text("IELTS-style Listening Practice")
                            .font(.body)
                            .bold()

                        Text("100 clips across 4 levels (Band 5-8) and 10 topic categories, designed for Japanese learners preparing for the IELTS exam.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Voices")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 6) {
                            voiceRow("Samantha", accent: "American")
                            voiceRow("Reed", accent: "American")
                            voiceRow("Daniel", accent: "British")
                            voiceRow("Flo", accent: "British")
                            voiceRow("Karen", accent: "Australian")
                            voiceRow("Moira", accent: "Irish")
                            voiceRow("Rishi", accent: "Indian")
                            voiceRow("Tessa", accent: "South African")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func voiceRow(_ name: String, accent: String) -> some View {
        HStack {
            Text(name)
                .font(.subheadline)
            Spacer()
            Text(accent)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
