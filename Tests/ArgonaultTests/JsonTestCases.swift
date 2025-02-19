import Argonault
import Foundation
import RegexBuilder

enum JsonTestCases: String, CaseIterable {
    case simpleWithStrings =
        """
            {
                "name": "John Doe",
                "email": "john.doe@example.com"
            }
        """
    func simpleWithStrings() -> Json {
        Json {
            JsonKey("name") { "John Doe" }
            JsonKey("email") { "john.doe@example.com" }
        }
    }
    case nestedObjects =
        """
            {
                "person": {
                    "name": "Jane Doe",
                    "age": 30,
                    "address": {
                        "street": "123 Main St",
                        "city": "Anytown",
                        "state": "CA"
                    }
                }
            }
        """
    func nestedObjects() -> Json {
        Json {
            JsonKey("person") {
                Json {
                    JsonKey("name") { "Jane Doe" }
                    JsonKey("age") { 30 }
                    JsonKey("address") {
                        Json {
                            JsonKey("street") { "123 Main St" }
                            JsonKey("city") { "Anytown" }
                            JsonKey("state") { "CA" }
                        }
                    }
                }
            }
        }
    }
    case arrays =
        """
            {
                "fruits": ["apple", "banana", "cherry"]
            }
        """
    func arrays() -> Json {
        Json {
            JsonKey("fruits") {
                ArrayField {
                    "apple"
                    "banana"
                    "cherry"
                }
            }
        }
    }
    case mixedDataTypes =
        """
            {
                "id": 123,
                "isActive": true,
                "tags": ["swift", "json", "ios"],
                "details": {
                    "height": 5.9,
                    "weight": 160.5
                }
            }
        """
    func mixedDataTypes() -> Json {
        Json {
            JsonKey("id") { 123 }
            JsonKey("isActive") { true }
            JsonKey("tags") {
                ArrayField {
                    "swift"
                    "json"
                    "ios"
                }
            }
            JsonKey("details") {
                Json {
                    JsonKey("height") { 5.9 }
                    JsonKey("weight") { 160.5 }
                }
            }
        }
    }
    case nestedArrays =
        """
            {
                "matrix": [
                    [1, 2, 3],
                    [4, 5, 6],
                    [7, 8, 9]
                ]
            }
        """
    func nestedArrays() -> Json {
        Json {
            JsonKey("matrix") {
                ArrayField {
                    ArrayField {
                        1
                        2
                        3
                    }
                    ArrayField {
                        4
                        5
                        6
                    }
                    ArrayField {
                        7
                        8
                        9
                    }
                }
            }
        }
    }
    case nullValues =
        """
            {
                "name": "Alice",
                "middleName": null,
                "age": 25
            }
        """
    func nullValues() -> Json {
        Json {
            JsonKey("name") { "Alice" }
            JsonKey("middleName") { nil }
            JsonKey("age") { 25 }
        }
    }
    case booleanValues =
        """
            {
                "isPublic": true,
                "isArchived": false
            }
        """
    func booleanValues() -> Json {
        Json {
            JsonKey("isPublic") { true }
            JsonKey("isArchived") { false }
        }
    }
    case numbers =
        """
            {
                "integerValue": 42,
                "floatValue": 3.14
            }
        """
    func numbers() -> Json {
        Json {
            JsonKey("integerValue") { 42 }
            JsonKey("floatValue") { 3.14 }
        }
    }
    case complexNestedStructures =
        """
            {
                "users": [
                    {
                        "id": 1,
                        "name": "Bob",
                        "roles": ["admin", "user"]
                    },
                    {
                        "id": 2,
                        "name": "Alice",
                        "roles": ["user"]
                    }
                ],
                "settings": {
                    "theme": "dark",
                    "notifications": {
                        "email": true,
                        "sms": false
                    }
                }
            }
        """
    func complexNestedStructures() -> Json {
        Json {
            JsonKey("users") {
                ArrayField {
                    Json {
                        JsonKey("id") { 1 }
                        JsonKey("name") { "Bob" }
                        JsonKey("roles") {
                            ArrayField {
                                ("admin")
                                ("user")
                            }
                        }
                    }
                    Json {
                        JsonKey("id") { 2 }
                        JsonKey("name") { "Alice" }
                        JsonKey("roles") {
                            ArrayField {
                                ("user")
                            }
                        }
                    }
                }
            }
            JsonKey("settings") {
                Json {
                    JsonKey("theme") { "dark" }
                    JsonKey("notifications") {
                        Json {
                            JsonKey("email") { true }
                            JsonKey("sms") { false }
                        }
                    }
                }
            }
        }
    }
    case emptyObjectsAndArrays =
        """
            {
                "emptyObject": {},
                "emptyArray": []
            }
        """
    func emptyObjectsAndArrays() -> Json {
        Json {
            JsonKey("emptyObject") { Json {} }
            JsonKey("emptyArray") { ArrayField {} }
        }
    }
    case datesAsStrings =
        """
            {
                "event": {
                    "name": "Conference",
                    "date": "2023-10-15T09:00:00Z"
                }
            }
        """
    func datesAsStrings() -> Json {
        Json {
            JsonKey("event") {
                Json {
                    JsonKey("name") { "Conference" }
                    JsonKey("date") {
                        {
                            let components = DateComponents(
                                timeZone: .gmt, year: 2023, month: 10, day: 15, hour: 9)
                            let calendar = Calendar(identifier: .gregorian)
                            let date = calendar.date(from: components)
                            guard let date else { return nil }
                            let formatter = ISO8601DateFormatter()
                            return formatter.string(from: date)
                        }()
                    }
                }
            }
        }
    }
    case largeNumbers =
        """
            {
                "largeNumber": 1234567890123456789,
                "smallNumber": 1.23456e-10
            }
        """
    func largeNumbers() -> Json {
        Json {
            JsonKey("largeNumber") { 1_234_567_890_123_456_789 }
            JsonKey("smallNumber") { 0.000000000123456 }
        }
    }
    case mixedNestedArraysAndObjects =
        """
            {
                "data": [
                    {
                        "id": 1,
                        "values": [1, 2, 3]
                    },
                    {
                        "id": 2,
                        "values": [4, 5, 6]
                    }
                ]
            }
        """
    func mixedNestedArraysAndObjects() -> Json {
        Json {
            JsonKey("data") {
                ArrayField {
                    Json {
                        JsonKey("id") { 1 }
                        JsonKey("values") {
                            ArrayField {
                                1
                                2
                                3
                            }
                        }
                    }
                    Json {
                        JsonKey("id") { 2 }
                        JsonKey("values") {
                            ArrayField {
                                4
                                5
                                6
                            }
                        }
                    }
                }
            }
        }
    }
    case unicodeCharacters =
        """
            {
                "unicode": "こんにちは世界",
                "emoji": "😊🎉🚀"
            }
        """
    func unicodeCharacters() -> Json {
        Json {
            JsonKey("unicode") { "こんにちは世界" }
            JsonKey("emoji") { "😊🎉🚀" }
        }
    }
    case deeplyNestedStructures =
        """
            {
                "level1": {
                    "level2": {
                        "level3": {
                            "level4": {
                                "value": "Deeply nested"
                            }
                        }
                    }
                }
            }
        """
    func deeplyNestedStructures() -> Json {
        Json {
            JsonKey("level1") {
                Json {
                    JsonKey("level2") {
                        Json {
                            JsonKey("level3") {
                                Json {
                                    JsonKey("level4") {
                                        Json { JsonKey("value") { "Deeply nested" } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    case multipleDataTypesInArray =
        """
            {
                "mixedArray": [1, "two", 3.0, true, null, { "key": "value" }]
            }
        """
    func multipleDataTypesInArray() -> Json {
        Json {
            JsonKey("mixedArray") {
                ArrayField {
                    1
                    "two"
                    3.0
                    true
                    nil
                    Json {
                        JsonKey("key") { "value" }
                    }
                }
            }
        }
    }
    case largeNestedArrays =
        """
            {
                "largeArray": [
                    [1, 2, 3, 4, 5],
                    [6, 7, 8, 9, 10],
                    [11, 12, 13, 14, 15],
                    [16, 17, 18, 19, 20],
                    [21, 22, 23, 24, 25]
                ]
            }
        """
    func largeNestedArrays() -> Json {
        Json {
            JsonKey("largeArray") {
                ArrayField {
                    ArrayField {
                        1
                        2
                        3
                        4
                        5
                    }
                    ArrayField {
                        6
                        7
                        8
                        9
                        10
                    }
                    ArrayField {
                        11
                        12
                        13
                        14
                        15
                    }
                    ArrayField {
                        16
                        17
                        18
                        19
                        20
                    }
                    ArrayField {
                        21
                        22
                        23
                        24
                        25
                    }
                }
            }
        }
    }
    case emptyStrings =
        """
            {
                "emptyString": "",
                "nonEmptyString": "Hello"
            }
        """
    func emptyStrings() -> Json {
        Json {
            JsonKey("emptyString") { "" }
            JsonKey("nonEmptyString") { "Hello" }
        }
    }
    case escape =
        """
        	{
        		"message": "Hello, world! 🌍",
        		"specialChars": "!@#$%^&*()_+{}:\\\"<>?[];',./`~",
        		"whitespace": "   This has leading and trailing spaces   ",
        		"newlines": "This\\nhas\\nnewlines",
        		"unicodeEscaped": "\\u0048\\u0065\\u006C\\u006C\\u006F",
        	}
        """
    func escape() -> Json {
        Json {
            JsonKey("message") { "Hello, world! 🌍" }
            JsonKey("specialChars") { "!@#$%^&*()_+{}:\\\"<>?[];',./`~" }
            JsonKey("whitespace") { "   This has leading and trailing spaces   " }
            JsonKey("newlines") { #"This\nhas\nnewlines"# }
            JsonKey("unicodeEscaped") { "\\u0048\\u0065\\u006C\\u006C\\u006F" }
        }
    }
    case complexMixedTypes =
        """
            {
                "mixed": {
                    "string": "Hello",
                    "number": 42,
                    "boolean": true,
                    "nullValue": null,
                    "array": [1, "two", false],
                    "object": {
                        "nestedString": "World",
                        "nestedNumber": 3.14
                    }
                }
            }
        """
    func complexMixedTypes() -> Json {
        Json {
            JsonKey("mixed") {
                Json {
                    JsonKey("string") { "Hello" }
                    JsonKey("number") { 42 }
                    JsonKey("boolean") { true }
                    JsonKey("nullValue") { nil }
                    JsonKey("array") {
                        ArrayField {
                            1
                            "two"
                            false
                        }
                    }
                    JsonKey("object") {
                        Json {
                            JsonKey("nestedString") { "World" }
                            JsonKey("nestedNumber") { 3.14 }
                        }
                    }
                }
            }
        }
    }
    case largeString =
        """
            {
            "largeString": "This is a very large string with many characters. It is used to test how well the JSON builder handles large strings. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
            }
        """
    func largeString() -> Json {
        Json {
            JsonKey("largeString") {
                "This is a very large string with many characters. It is used to test how well the JSON builder handles large strings. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
            }
        }
    }

    var builder: () -> Json {
        switch self {
        case .simpleWithStrings: return simpleWithStrings
        case .nestedObjects: return nestedObjects
        case .arrays: return arrays
        case .mixedDataTypes: return mixedDataTypes
        case .nestedArrays: return nestedArrays
        case .nullValues: return nullValues
        case .booleanValues: return booleanValues
        case .numbers: return numbers
        case .complexNestedStructures: return complexNestedStructures
        case .emptyObjectsAndArrays: return emptyObjectsAndArrays
        case .datesAsStrings: return datesAsStrings
        case .largeNumbers: return largeNumbers
        case .mixedNestedArraysAndObjects: return mixedNestedArraysAndObjects
        case .unicodeCharacters: return unicodeCharacters
        case .deeplyNestedStructures: return deeplyNestedStructures
        case .multipleDataTypesInArray: return multipleDataTypesInArray
        case .largeNestedArrays: return largeNestedArrays
        case .emptyStrings: return emptyStrings
        case .complexMixedTypes: return complexMixedTypes
        case .largeString: return largeString
        case .escape: return escape
        }
    }
}
