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
                    numberName
                } else {
                    nil
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
                        numberName
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

@Test func sample() async throws {

    let members: [(name: String, age: Int, languages: [String])] = [
        ("Jason", 40, ["Swift", "Objective-C"]),
        ("Orfeu", 20, ["Swift"]),
    ]

    let json = Json {
        JsonKey("name") { "Argonaults" }
        JsonKey("members") {
            ArrayField {
                for member in members {
                    Json {
                        JsonKey("name") { member.name }
                        JsonKey("age") { member.age }
                        JsonKey("languages") {
                            ArrayField {
                                for language in member.languages {
                                    Json {
                                        JsonKey("name") { language }
                                    }
                                }
                            }
                        }
                        JsonKey("is_senior") {
                            member.age > 30 && member.languages.count > 1
                        }
                    }
                }
            }
        }
    }

    let asString = try #require(json.render(writingOptions: [.prettyPrinted, .sortedKeys]))
    let expected = """
        {
          "name": "Argonaults",
          "members": [
            {
              "name": "Jason",
              "age": 40,
              "languages": [{ "name": "Swift" }, { "name": "Objective-C" }],
              "is_senior": true
            },
            {
              "name": "Orfeu",
              "age": 20,
              "languages": [{ "name": "Swift" }],
              "is_senior": false
            }
          ]
        }
        """
    let expectedFormatted = try #require(
        try? expected.formatJson(writeOptions: [.prettyPrinted, .sortedKeys]))
    #expect(asString == expectedFormatted)
}
