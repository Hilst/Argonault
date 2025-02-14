import Foundation
import Testing

@testable import Argonault

@Test("should map all json builders", arguments: JsonTestCases.allCases)
func jsonBuilder(_ testCase: JsonTestCases) async throws {
    let format: JSONSerialization.WritingOptions = [
        .prettyPrinted, .sortedKeys, .withoutEscapingSlashes,
    ]
    let stringFromCase = try testCase.rawValue.formatJson(writeOptions: format)
    let json = testCase.builder()
    let stringFromJson = json.render(writingOptions: format)
    #expect(stringFromJson == stringFromCase)
}

struct BuilderTests {
    let allIndex = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let indexesWithText = [1, 3, 4, 6, 8, 9]
    let transform: (Int?) -> String? = { number in
        if let number {
            return String(number)
        }
        return nil
    }
    @Test("JsonField should build with conditionals and iterations")
    func jsonBuilderForElements() async throws {
        let array = try ArrayField {
            for index in allIndex {
                if indexesWithText.contains(index), let numberName = transform(index) {
                    StringField(numberName)
                } else {
                    NullField()
                }
            }
        }.model([String?].self)
        let expected = [nil, 1, nil, 3, 4, nil, 6, nil, 8, 9].map(transform)
        #expect(array == expected)
    }

    @Test("JsonKey should build with conditionals and iterations")
    func jsonKeyBuilderForElements() async throws {
        let dictionary = try Json {
            for index in allIndex {
                if indexesWithText.contains(index), let numberName = transform(index) {
                    JsonKey(numberName) {
                        StringField(numberName)
                    }
                } else {
                    let numberName = transform(index) ?? String(index)
                    JsonKey(numberName) {
                        NullField()
                    }
                }
            }
        }.model([String: String?].self)
        let expected = [
            "0": nil, "1": "1", "2": nil,
            "3": "3", "4": "4", "5": nil,
            "6": "6", "7": nil, "8": "8",
            "9": "9",
        ]
        // nil, 1, nil, 3, 4, nil, 6, nil, 8, 9]
        #expect(dictionary == expected)
    }
}
