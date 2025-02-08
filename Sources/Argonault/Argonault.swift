public protocol JsonElement { var format: String? { get } }
public typealias AnyJsonElement = any JsonElement

public protocol JsonConvertible { func render() -> String }

@resultBuilder
public enum JsonBuilder {
    public static func buildBlock(_ components: AnyJsonElement...) -> [AnyJsonElement] {
        components
    }

    public static func buildPartialBlock(first: [AnyJsonElement]) -> [AnyJsonElement] {
        first
    }

    public static func buildPartialBlock(
        accumulated: [AnyJsonElement],
        next: [AnyJsonElement]
    ) -> [AnyJsonElement] {
        accumulated + next
    }

    public static func buildExpression(_ expression: AnyJsonElement) -> [AnyJsonElement] {
        [expression]
    }

    public static func buildExpression(_ expression: [AnyJsonElement]) -> [AnyJsonElement] {
        expression
    }

    public static func buildEither(first component: [AnyJsonElement]) -> [AnyJsonElement] {
        component
    }

    public static func buildEither(second component: [AnyJsonElement]) -> [AnyJsonElement] {
        component
    }

    public static func buildOptional(_ component: [AnyJsonElement]?) -> [AnyJsonElement] {
        component ?? []
    }

    public static func buildArray(
        _ components: [[AnyJsonElement]]
    ) -> [AnyJsonElement] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [AnyJsonElement]) -> [AnyJsonElement] {
        component
    }
}

public typealias JsonBuilderFunc = () -> [AnyJsonElement]

extension [AnyJsonElement] {
    func render() -> String { self.compactMap { $0.format }.joined(separator: ",") }
}

public struct Key: JsonElement {
    let key: String
    public var format: String? { "\"\(key)\":\(elements.render())" }
    let elements: [AnyJsonElement]

    public init(_ key: String, @JsonBuilder _ elements: JsonBuilderFunc) {
        self.key = key
        self.elements = elements()
    }
}

public struct Json: JsonElement {
    let elements: [AnyJsonElement]
    public var format: String? { "{\(elements.render())}" }
    public init(@JsonBuilder _ elements: JsonBuilderFunc) {
        self.elements = elements()
    }
}

extension Json: JsonConvertible {
    public func render() -> String { format ?? "{}" }
}

public protocol DirectValueField: JsonElement {
    associatedtype Value
    var value: Value? { get set }
    func stringfy(_ value: Value) -> String
    init(_ builder: () -> Value?)
    init(_ value: Value?)
    init()
}

extension DirectValueField {
    public init(_ builder: () -> Value?) {
        self.init(builder())
    }

    public init(_ value: Value?) {
        self.init()
        self.value = value
    }

    public var format: String? {
        guard let value else { return nil }
        return stringfy(value)
    }
}

public struct StringField: DirectValueField {
    public init() {}
    public var value: String?
    public func stringfy(_ value: String) -> String { "\"\(value)\"" }
}

public struct NumberField<N: Numeric>: DirectValueField {
    public init() {}
    public var value: N?
    public func stringfy(_ value: N) -> String { "\(value)" }
}

public struct BooleanField: DirectValueField {
    public init() {}
    public var value: Bool?
    public func stringfy(_ value: Value) -> String { "\(value)" }
}

public struct NullField: JsonElement {
    public var format: String? { "null" }
    public init() {}
}

public struct ArrayField: JsonElement {
    public var format: String? {
        "[\(elements.render())]"
    }
    public let elements: [AnyJsonElement]
    public init(@JsonBuilder _ elements: JsonBuilderFunc) {
        self.elements = elements()
    }
}

extension String {
    public func cleanJson() -> String { Lexer(input: self).string() }
}
