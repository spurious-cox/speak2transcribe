import Foundation

/// Spoken "new line" becomes a line break and "new paragraph" a blank line.
/// Punctuation the recognizer puts around the words is dropped with them.
enum BreakWords {
    private static let pattern = try! NSRegularExpression(
        pattern: #"[\s,.;:!?]*\bnew\s+(line|paragraph)\b[\s,.;:!?]*"#,
        options: [.caseInsensitive])

    static func apply(_ text: String) -> String {
        let range = NSRange(text.startIndex..., in: text)
        var result = ""
        var last = text.startIndex
        for match in pattern.matches(in: text, range: range) {
            guard let whole = Range(match.range, in: text),
                  let kind = Range(match.range(at: 1), in: text) else { continue }
            result += text[last..<whole.lowerBound]
            result += text[kind].lowercased() == "paragraph" ? "\n\n" : "\n"
            last = whole.upperBound
        }
        result += text[last...]
        return result
    }
}
