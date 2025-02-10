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
