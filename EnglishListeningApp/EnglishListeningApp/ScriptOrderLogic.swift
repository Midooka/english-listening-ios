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
}

enum PrefixResult: Equatable {
    case correct
    case validPrefix
    case wrong(Int)   // 間違ったトークンの index
}
