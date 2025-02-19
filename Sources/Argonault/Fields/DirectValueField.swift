// MARK: - declaration
public protocol DirectValueField: JsonElement {
    func stringfy() -> String
}
extension DirectValueField {
    public var format: String? { return self.stringfy() }
}

// MARK: - string conf
extension String: DirectValueField {
    public func stringfy() -> String { "\"\(self)\"" }
}

// MARK: - number conf
protocol NumberField: DirectValueField {}
extension NumberField { public func stringfy() -> String { "\(self)" } }
extension Double: NumberField {}
extension Float: NumberField {}
extension Int: NumberField {}
extension UInt: NumberField {}

// MARK: - bool conf
extension Bool: DirectValueField {
    public func stringfy() -> String { "\(self)" }
}
