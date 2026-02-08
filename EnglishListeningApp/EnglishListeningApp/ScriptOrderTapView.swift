import SwiftUI

struct ScriptOrderTapView: View {
    let transcript: String
    let onComplete: () -> Void

    @State private var answer: [String] = []
    @State private var pool: [IndexedToken] = []
    @State private var selected: [IndexedToken] = []
    @State private var wrongIndex: Int? = nil
    @State private var isComplete: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tap words in the correct order")
                .font(.headline)

            // Selected tokens
            selectedSection

            Divider()

            // Available tokens
            poolSection

            // Undo / Reset
            controlButtons

            if isComplete {
                completionBanner
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear(perform: setup)
    }

    // MARK: - Sections

    private var selectedSection: some View {
        FlowLayout(spacing: 6) {
            ForEach(Array(selected.enumerated()), id: \.element.id) { index, token in
                Text(token.token)
                    .font(.body.monospaced())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(colorForSelected(at: index))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .topLeading)
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var poolSection: some View {
        FlowLayout(spacing: 6) {
            ForEach(pool) { token in
                Button { selectToken(token) } label: {
                    Text(token.token)
                        .font(.body.monospaced())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(wrongIndex != nil || isComplete)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .topLeading)
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: undo) {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }
            .disabled(selected.isEmpty || isComplete)

            Button(action: reset) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .disabled(selected.isEmpty || isComplete)
        }
    }

    private var completionBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Correct!")
                    .font(.headline)
                    .foregroundStyle(.green)
            }
            Text(transcript)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func setup() {
        answer = ScriptOrderLogic.tokenize(transcript)
        let indexed = answer.enumerated().map { IndexedToken(id: $0.offset, token: $0.element) }
        pool = indexed.shuffled()
        selected = []
        wrongIndex = nil
        isComplete = false
    }

    private func selectToken(_ token: IndexedToken) {
        guard wrongIndex == nil, !isComplete else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            pool.removeAll { $0.id == token.id }
            selected.append(token)
        }

        let result = ScriptOrderLogic.checkPrefix(
            selected: selected.map(\.token),
            answer: answer
        )

        switch result {
        case .correct:
            isComplete = true
            onComplete()
        case .validPrefix:
            wrongIndex = nil
        case .wrong:
            wrongIndex = selected.count - 1
        }
    }

    private func undo() {
        guard let last = selected.popLast() else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            pool.append(last)
            wrongIndex = nil
        }
    }

    private func reset() {
        withAnimation(.easeInOut(duration: 0.2)) {
            let all = selected + pool
            pool = all.shuffled()
            selected = []
            wrongIndex = nil
        }
    }

    private func colorForSelected(at index: Int) -> Color {
        if let wi = wrongIndex, index == wi {
            return .red
        }
        return .blue
    }
}

// MARK: - IndexedToken

private struct IndexedToken: Identifiable {
    let id: Int
    let token: String
}

// MARK: - FlowLayout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return computeLayout(sizes: sizes, maxWidth: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let layout = computeLayout(sizes: sizes, maxWidth: bounds.width)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + layout.positions[index].x,
                             y: bounds.minY + layout.positions[index].y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(sizes: [CGSize], maxWidth: CGFloat) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for size in sizes {
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, x - spacing)
        }

        return (positions, CGSize(width: totalWidth, height: y + rowHeight))
    }
}
