import Foundation

public protocol JsonConvertible: JsonElement {
    var data: Data? { get }
    func render(
        readingOptions: JSONSerialization.ReadingOptions,
        writingOptions: JSONSerialization.WritingOptions
    ) -> String?
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
            let newData = try? JSONSerialization.data(
                withJSONObject: object, options: writingOptions)
        else { return nil }
        return String(data: newData, encoding: .utf8)
    }

    public func model<T>(_ type: T.Type, decoder: JSONDecoder? = nil) throws -> T
    where T: Decodable {
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
