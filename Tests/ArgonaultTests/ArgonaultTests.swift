import Testing

@testable import Argonault

@Test("should map all json builders", arguments: JsonTestCases.allCases)
func jsonBuilder(_ testCase: JsonTestCases) async throws {
	let stringFromCase = try testCase.rawValue.formatJson(writeOptions: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    let json = testCase.builder()
	let stringFromJson = json.render(writingOptions: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    #expect(stringFromJson == stringFromCase)
}

