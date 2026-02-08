import Foundation

enum ScriptOrderLogic {

    /// transcript を単語トークンに分割する。
    /// 句読点は直前の単語に付属させる（例: "him." → "him."）。
    static func tokenize(_ transcript: String) -> [String] {
        transcript.split(separator: " ").map(String.init)
    }

    /// selected が answer の先頭（prefix）として正しいか判定する。
    /// 戻り値: .correct（完全一致）/ .validPrefix（途中まで正しい）/ .wrong(index)（間違った位置）
    static func checkPrefix(selected: [String], answer: [String]) -> PrefixResult {
        for (i, token) in selected.enumerated() {
            guard i < answer.count else { return .wrong(i) }
            if token != answer[i] { return .wrong(i) }
        }
        return selected.count == answer.count ? .correct : .validPrefix
    }

    /// tokens をシャッフルして返す（Fisher-Yates）。
    static func shuffled(_ tokens: [String]) -> [String] {
        var arr = tokens
        arr.shuffle()
        return arr
    }

    // MARK: - Blank Selection (Cloze)

    /// レベルに応じたブランク数
    static func blankCount(for level: Int) -> Int {
        switch level {
        case 1: return 5
        case 2: return 7
        default: return 10
        }
    }

    /// ストップワード（冠詞・be動詞・前置詞など）
    private static let stopWords: Set<String> = [
        "a", "an", "the", "is", "am", "are", "was", "were", "be", "been", "being",
        "i", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them",
        "my", "his", "its", "our", "your", "their",
        "in", "on", "at", "to", "for", "of", "with", "by", "from", "as",
        "and", "but", "or", "not", "no", "so", "if", "do", "did", "does",
        "had", "has", "have", "that", "this", "will", "would", "could", "should"
    ]

    /// トークンからアルファベット部分だけ取り出して小文字化（句読点除去）
    private static func bareWord(_ token: String) -> String {
        String(token.unicodeScalars.filter { CharacterSet.letters.contains($0) }).lowercased()
    }

    /// 内容語かどうか判定（ストップワードでなければ内容語）
    private static func isContentWord(_ token: String) -> Bool {
        let bare = bareWord(token)
        return !bare.isEmpty && !stopWords.contains(bare)
    }

    /// レベルに応じて均等分散でブランクインデックスを選出する。
    /// トークン数 ≤ ブランク数なら全インデックスを返す（現行動作と同等）。
    static func selectBlankIndices(tokens: [String], level: Int) -> Set<Int> {
        let count = blankCount(for: level)
        guard tokens.count > count else {
            return Set(tokens.indices)
        }

        // 内容語インデックスを収集
        var contentIndices: [Int] = []
        var otherIndices: [Int] = []
        for (i, token) in tokens.enumerated() {
            if isContentWord(token) {
                contentIndices.append(i)
            } else {
                otherIndices.append(i)
            }
        }

        // 内容語が足りなければストップワードも候補に加える
        var candidates = contentIndices
        if candidates.count < count {
            candidates += otherIndices
        }
        candidates.sort()

        // 均等分散で count 個選出
        guard candidates.count > count else {
            return Set(candidates)
        }

        var selected = Set<Int>()
        let step = Double(candidates.count) / Double(count)
        for i in 0..<count {
            let idx = Int(Double(i) * step + step / 2)
            let clamped = min(idx, candidates.count - 1)
            selected.insert(candidates[clamped])
        }

        // 重複で足りない場合は追加（まれなケース）
        var ci = 0
        while selected.count < count && ci < candidates.count {
            selected.insert(candidates[ci])
            ci += 1
        }

        return selected
    }
}

enum PrefixResult: Equatable {
    case correct
    case validPrefix
    case wrong(Int)   // 間違ったトークンの index
}
