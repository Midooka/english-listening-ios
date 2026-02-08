import SwiftUI

struct ScriptOrderTapView: View {
    let transcript: String
    let level: Int
    let onComplete: () -> Void

    /// 全トークン（固定語 + ブランク語）の並び
    @State private var allTokens: [ClozeToken] = []
    /// ブランク位置の正解単語列（出現順）
    @State private var answer: [String] = []
    /// プール（ブランク単語のシャッフル）
    @State private var pool: [IndexedToken] = []
    /// ユーザーが選択したブランク単語列
    @State private var selected: [IndexedToken] = []
    @State private var wrongIndex: Int? = nil
    @State private var isComplete: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fill in the blanks")
                .font(.headline)

            // Inline cloze display
            clozeSection

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

    private var clozeSection: some View {
        FlowLayout(spacing: 4) {
            ForEach(Array(allTokens.enumerated()), id: \.element.id) { _, token in
                if token.isBlank {
                    blankView(for: token)
                } else {
                    // 固定語: グレーテキスト
                    Text(token.word)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 6)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .topLeading)
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func blankView(for token: ClozeToken) -> some View {
        let blankOrder = token.blankOrder
        if blankOrder < selected.count {
            // 回答済みブランク
            let filledToken = selected[blankOrder]
            Text(filledToken.token)
                .font(.body.monospaced())
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(colorForFilled(blankOrder: blankOrder))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else if blankOrder == selected.count {
            // 次に埋まるブランク（ハイライト）
            Text("___")
                .font(.body.monospaced())
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.15))
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue, lineWidth: 1.5)
                )
        } else {
            // 未到達のブランク
            Text("___")
                .font(.body.monospaced())
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .foregroundStyle(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
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
        let tokens = ScriptOrderLogic.tokenize(transcript)
        let blankIndices = ScriptOrderLogic.selectBlankIndices(tokens: tokens, level: level)

        var blankOrder = 0
        var built: [ClozeToken] = []
        var answerWords: [String] = []
        var poolTokens: [IndexedToken] = []

        for (i, word) in tokens.enumerated() {
            let isBlank = blankIndices.contains(i)
            built.append(ClozeToken(id: i, word: word, isBlank: isBlank, blankOrder: isBlank ? blankOrder : -1))
            if isBlank {
                answerWords.append(word)
                poolTokens.append(IndexedToken(id: blankOrder, token: word))
                blankOrder += 1
            }
        }

        allTokens = built
        answer = answerWords
        pool = poolTokens.shuffled()
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

    private func colorForFilled(blankOrder: Int) -> Color {
        if let wi = wrongIndex, blankOrder == wi {
            return .red
        }
        return .blue
    }
}

// MARK: - Models

private struct ClozeToken: Identifiable {
    let id: Int
    let word: String
    let isBlank: Bool
    /// ブランク内での順番（0-based）。固定語は -1。
    let blankOrder: Int
}

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
