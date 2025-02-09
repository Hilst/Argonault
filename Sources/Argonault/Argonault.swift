import Foundation

public protocol JsonElement { var format: String? { get } }
public typealias AnyJsonElement = any JsonElement

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

extension Json: JsonConvertible { }

public protocol JsonConvertible: JsonElement {
	var data: Data? { get }
	func render(readingOptions: JSONSerialization.ReadingOptions, writingOptions: JSONSerialization.WritingOptions) -> String?
	func object(readingOptions: JSONSerialization.ReadingOptions) -> Any?
	func model<T>(_ type: T.Type, decoder: JSONDecoder?) throws -> T where T: Decodable
}

extension JsonConvertible {
	public var data: Data? { format?.data(using: .utf8) }

	public func object(readingOptions: JSONSerialization.ReadingOptions = []) -> Any? {
		guard let data else { return nil }
		return try? JSONSerialization.jsonObject(with: data, options: readingOptions)
	}

	public func render(
		readingOptions: JSONSerialization.ReadingOptions = [],
		writingOptions: JSONSerialization.WritingOptions = []
	) -> String? {
		guard !readingOptions.isEmpty || !writingOptions.isEmpty else { return format }
		guard let object = object(readingOptions: readingOptions),
			  let newData = try? JSONSerialization.data(withJSONObject: object, options: writingOptions)
		else { return nil }
		return String(data: newData, encoding: .utf8)
	}

	public func model<T>(_ type: T.Type, decoder: JSONDecoder? = nil) throws -> T where T: Decodable {
		guard let data else { throw NSError() }
		return try (decoder ?? JSONDecoder()).decode(type.self, from: data)
	}
}

extension String {
	public func formatJson(
		readOptions: JSONSerialization.ReadingOptions = [],
		writeOptions: JSONSerialization.WritingOptions
	) throws -> String {
		let data = try self.data(using: .utf8).unwrappOrThrow()
		let obj = try JSONSerialization.jsonObject(with: data, options: readOptions)
		let newData = try JSONSerialization.data(withJSONObject: obj, options: writeOptions)
		return try String(data: newData, encoding: .utf8).unwrappOrThrow()
	}
}

extension Optional {
	enum UnwrappingError: Error { case nilValue }
	func unwrappOrThrow() throws -> Wrapped {
		guard let unwrapped = self else { throw UnwrappingError.nilValue }
		return unwrapped
	}
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
