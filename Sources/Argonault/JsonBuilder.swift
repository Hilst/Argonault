public protocol JsonElement { var format: String? { get } }

@resultBuilder
public enum JsonBuilder { }

// MARK: - Builder for any JsonElement
extension JsonBuilder {
    public static func buildBlock(_ components: any JsonElement...) -> [any JsonElement] { components }
    public static func buildPartialBlock(first: [any JsonElement]) -> [any JsonElement] { first }
    public static func buildPartialBlock( accumulated: [any JsonElement], next: [any JsonElement] ) -> [any JsonElement] { accumulated + next }
    public static func buildExpression(_ expression: any JsonElement) -> [any JsonElement] { [expression] }
    public static func buildExpression(_ expression: [any JsonElement]) -> [any JsonElement] { expression }
    public static func buildEither(first component: [any JsonElement]) -> [any JsonElement] { component }
    public static func buildEither(second component: [any JsonElement]) -> [any JsonElement] { component }
    public static func buildOptional(_ component: [any JsonElement]?) -> [any JsonElement] { component ?? [] }
    public static func buildArray( _ components: [[any JsonElement]] ) -> [any JsonElement] { components.flatMap { $0 } }
    public static func buildLimitedAvailability(_ component: [any JsonElement]) -> [any JsonElement] { component }
}

// MARK: - Builder for Keyed Json
extension JsonBuilder {
	public static func buildBlock(_ components: JsonKey...) -> [JsonKey] { components }
	public static func buildPartialBlock(first: [JsonKey]) -> [JsonKey] { first }
	public static func buildPartialBlock( accumulated: [JsonKey], next: [JsonKey] ) -> [JsonKey] { accumulated + next }
	public static func buildExpression(_ expression: JsonKey) -> [JsonKey] { [expression] }
	public static func buildExpression(_ expression: [JsonKey]) -> [JsonKey] { expression }
	public static func buildEither(first component: [JsonKey]) -> [JsonKey] { component }
	public static func buildEither(second component: [JsonKey]) -> [JsonKey] { component }
	public static func buildOptional(_ component: [JsonKey]?) -> [JsonKey] { component ?? [] }
	public static func buildArray( _ components: [[JsonKey]] ) -> [JsonKey] { components.flatMap { $0 } }
	public static func buildLimitedAvailability(_ component: [JsonKey]) -> [JsonKey] { component }
}
