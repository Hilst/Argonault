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
            "name" <- "John Doe"
            "email" <- "john.doe@example.com"
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
            "person"
                <- Json {
                    "name" <- "Jane Doe"
                    "age" <- 30
                    "address"
                        <- Json {
                            "street" <- "123 Main St"
                            "city" <- "Anytown"
                            "state" <- "CA"
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
            "fruits"
                <- ArrayField {
                    "apple"
                    "banana"
                    "cherry"
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
            "id" <- 123
            "isActive" <- true
            "tags"
                <- ArrayField {
                    "swift"
                    "json"
                    "ios"
                }
            "details"
                <- Json {
                    "height" <- 5.9
                    "weight" <- 160.5
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
            "matrix"
                <- ArrayField {
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
            "name" <- "Alice"
            "middleName" <- nil
            "age" <- 25
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
            "isPublic" <- true
            "isArchived" <- false
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
            "integerValue" <- 42
            "floatValue" <- 3.14
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
            "users"
                <- ArrayField {
                    Json {
                        "id" <- 1
                        "name" <- "Bob"
                        "roles"
                            <- ArrayField {
                                "admin"
                                "user"
                            }
                    }
                    Json {
                        "id" <- 2
                        "name" <- "Alice"
                        "roles"
                            <- ArrayField {
                                "user"
                            }
                    }
                }
            "settings"
                <- Json {
                    "theme" <- "dark"
                    "notifications"
                        <- Json {
                            "email" <- true
                            "sms" <- false
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
            "emptyObject" <- Json {}
            "emptyArray" <- ArrayField {}
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
            "event"
                <- Json {
                    "name" <- "Conference"
                    "date"
                        <- {
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
    case largeNumbers =
        """
            {
                "largeNumber": 1234567890123456789,
                "smallNumber": 1.23456e-10
            }
        """
    func largeNumbers() -> Json {
        Json {
            "largeNumber" <- 1_234_567_890_123_456_789
            "smallNumber" <- 0.000000000123456
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
            "data"
                <- ArrayField {
                    Json {
                        "id" <- 1
                        "values"
                            <- ArrayField {
                                1
                                2
                                3
                            }
                    }
                    Json {
                        "id" <- 2
                        "values"
                            <- ArrayField {
                                4
                                5
                                6
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
            "unicode" <- "こんにちは世界"
            "emoji" <- "😊🎉🚀"
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
            "level1"
                <- Json {
                    "level2"
                        <- Json {
                            "level3"
                                <- Json {
                                    "level4"
                                        <- Json {
                                            "value" <- "Deeply nested"
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
            "mixedArray"
                <- ArrayField {
                    1
                    "two"
                    3.0
                    true
                    nil
                    Json {
                        "key" <- "value"
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
            "largeArray"
                <- ArrayField {
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
    case emptyStrings =
        """
            {
                "emptyString": "",
                "nonEmptyString": "Hello"
            }
        """
    func emptyStrings() -> Json {
        Json {
            "emptyString" <- ""
            "nonEmptyString" <- "Hello"
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
            "message" <- "Hello, world! 🌍"
            "specialChars" <- "!@#$%^&*()_+{}:\\\"<>?[];',./`~"
            "whitespace" <- "   This has leading and trailing spaces   "
            "newlines" <- #"This\nhas\nnewlines"#
            "unicodeEscaped" <- "\\u0048\\u0065\\u006C\\u006C\\u006F"
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
            "mixed"
                <- Json {
                    "string" <- "Hello"
                    "number" <- 42
                    "boolean" <- true
                    "nullValue" <- nil
                    "array"
                        <- ArrayField {
                            1
                            "two"
                            false
                        }
                    "object"
                        <- Json {
                            "nestedString" <- "World"
                            "nestedNumber" <- 3.14
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
            "largeString"
                <- "This is a very large string with many characters. It is used to test how well the JSON builder handles large strings. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
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
