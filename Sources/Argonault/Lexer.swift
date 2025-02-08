import Foundation

private enum Token: Hashable {
    case openBrace
    case closeBrace
    case openBracket
    case closeBracket
    case comma
    case colon
    case quote
    case identifier(String)
    case escaped(String)

    private static let literals: [Token: String] = [
        .openBrace: "{",
        .closeBrace: "}",
        .openBracket: "[",
        .closeBracket: "]",
        .comma: ",",
        .colon: ":",
        .quote: "\"",
    ]

    var value: String {
        switch self {
        case .identifier(let value), .escaped(let value): return value
        default: return Token.literals[self] ?? ""
        }
    }
}

final class Lexer {
    private let input: String
    private var position: String.Index
    private var current: Character?
    private var insideString: Bool = false
    private var accumulated = String()

    private var tokens: [Token] = []

    init(input: String) {
        self.input = input
        self.position = input.startIndex
        self.current = input.first
        tokenize()
    }

    private func tokenize() {
        while let c = at(position) {
            if c.isQuotation && !isEscaped(position) {
                insideString.toggle()
                add(token: .quote)
                advance()
                continue
            }

            if c.isWhitespace && !insideString {
                advance()
                continue
            }

            if c.isCounterSlash, insideString {
                let escapeSequence = parseEscapeSequence()
                if !escapeSequence.isEmpty {
                    add(token: .escaped(escapeSequence))
                    continue
                }
            }

            if insideString {
                accumulated.append(c)
                advance()
                continue
            }

            switch c {
            case "{": add(token: .openBrace)
            case "}": add(token: .closeBrace)
            case "[": add(token: .openBracket)
            case "]": add(token: .closeBracket)
            case ",": add(token: .comma)
            case ":": add(token: .colon)
            default:
                accumulated.append(c)
            }
            advance()
        }

        // Add any remaining accumulated characters as an identifier
        if !accumulated.isEmpty {
            add(token: .identifier(accumulated))
        }
    }

    private func add(token: Token) {
        if !accumulated.isEmpty {
            tokens.append(.identifier(accumulated))
            accumulated = String()
        }
        tokens.append(token)
    }

    private func advance() {
        position = input.index(after: position)
        current = position < input.endIndex ? input[position] : nil
    }

    private func at(_ index: String.Index) -> Character? {
        index < input.endIndex ? input[index] : nil
    }

    private func peek(upfront: Int = 1) -> Character? {
        let peekIndex = input.index(position, offsetBy: upfront, limitedBy: input.endIndex)
        return peekIndex != nil ? input[peekIndex!] : nil
    }

    private func isEscaped(_ index: String.Index) -> Bool {
        guard index > input.startIndex else { return false }
        let previous = input.index(before: index)
        return input[previous].isCounterSlash && !isEscaped(previous)
    }

    private func parseEscapeSequence() -> String {
        guard let next = peek() else { return "" }
        let escapeSequence = next == "u" ? "\\u\(parseUnicode())" : "\\\(next)"
        advance()  // counter slash
        advance()  // character
        return escapeSequence
    }

    private func parseUnicode() -> String {
        var unicode = [Character](repeating: " ", count: 4)
        for i in 0..<4 {
			if let char = peek(upfront: 2), char.isHexDigit {
                unicode[i] = char
                advance()
                continue
            }
            break
        }
		return String(unicode).trimmingCharacters(in: .whitespaces)
    }

    func string() -> String {
        var result = ""
        var openedQuotes = false
        for tk in tokens {
            if case let .identifier(id) = tk {
                result += openedQuotes ? id.cleanUnescaped() : id
                continue
            }
			if case let .escaped(sequence) = tk {
				result += sequence
				continue
			}
            if tk == .quote { openedQuotes.toggle() }
            result += tk.value
        }
        return result
    }
}

extension String {
    func cleanUnescaped() -> String {
		self.replacingOccurrences(of: "\n", with: "")
			.replacingOccurrences(of: "\t", with: "")
			.replacingOccurrences(of: "\r", with: "")

    }
}

extension Character {
    var isQuotation: Bool { self == "\"" }
    var isCounterSlash: Bool { self == "\\" }
    var isWhitespace: Bool { self == " " || self == "\n" || self == "\t" || self == "\r" }
}
