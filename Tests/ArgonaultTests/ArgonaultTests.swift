import Testing

@testable import Argonault

@Test("should map all json builders", arguments: JsonTestCases.allCases)
func jsonBuilder(_ testCase: JsonTestCases) async throws {
    let stringFromCase = testCase.rawValue.cleanJson()
    let json = testCase.builder()
    let stringFromJson = json.render()
    #expect(stringFromJson == stringFromCase)
}

