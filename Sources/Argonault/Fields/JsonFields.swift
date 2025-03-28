public typealias JsonBuilderFunc = () -> [JsonElement]

extension [JsonElement] {
    func render() -> String { self.compactMap { $0.format }.joined(separator: ",") }
}

infix operator <- : AssignmentPrecedence
public func <- (lhs: String, rhs: JsonElement?) -> JsonKey {
    JsonKey(lhs, { [rhs] })
}

public func <- (lhs: String, @JsonBuilder rhs: JsonBuilderFunc) -> JsonKey {
    JsonKey(lhs, rhs)
}

public struct JsonKey: JsonElement {
    let key: String
    public var format: String? { "\"\(key)\":\(elements.render())" }
    let elements: [JsonElement]

	internal init(_ key: String, @JsonBuilder _ elements: JsonBuilderFunc) {
        self.key = key
        self.elements = elements()
    }
}

public struct Json: JsonElement {
    let elements: [JsonElement]
    public var format: String? { "{\(elements.render())}" }
    public init(@JsonBuilder _ elements: () -> [JsonKey]) {
        self.elements = elements()
    }
}

extension Json: JsonConvertible {}

public struct ArrayField: JsonElement {
    let elements: [JsonElement]
    public var format: String? { "[\(elements.render())]" }
    public init(@JsonBuilder _ elements: JsonBuilderFunc) {
        self.elements = elements()
    }
}

extension ArrayField: JsonConvertible {}

struct NullField: JsonElement {
    public var format: String? { "null" }
}
