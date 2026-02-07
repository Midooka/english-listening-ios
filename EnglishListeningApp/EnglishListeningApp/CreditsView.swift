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
                        Text("Audio Dataset")
                            .font(.headline)
                        
                        Text("LibriSpeech ASR corpus")
                            .font(.body)
                        
                        Text("OpenSLR SLR12")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Link("https://www.openslr.org/12", 
                             destination: URL(string: "https://www.openslr.org/12")!)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("License")
                            .font(.headline)
                        
                        Text("CC BY 4.0")
                            .font(.body)
                            .bold()
                        
                        Text("Creative Commons Attribution 4.0 International License")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Link("https://creativecommons.org/licenses/by/4.0/", 
                             destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Citation")
                            .font(.headline)
                        
                        Text("""
                        Vassil Panayotov, Guoguo Chen, Daniel Povey and Sanjeev Khudanpur. \
                        "LibriSpeech: an ASR corpus based on public domain audio books", \
                        ICASSP 2015.
                        """)
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
}
