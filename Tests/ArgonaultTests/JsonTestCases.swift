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
            Key("name") { StringField("John Doe") }
            Key("email") { StringField("john.doe@example.com") }
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
            Key("person") {
                Json {
                    Key("name") { StringField("Jane Doe") }
                    Key("age") { NumberField(30) }
                    Key("address") {
                        Json {
                            Key("street") { StringField("123 Main St") }
                            Key("city") { StringField("Anytown") }
                            Key("state") { StringField("CA") }
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
            Key("fruits") {
                ArrayField {
                    StringField("apple")
                    StringField("banana")
                    StringField("cherry")
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
            Key("id") { NumberField(123) }
            Key("isActive") { BooleanField(true) }
            Key("tags") {
                ArrayField {
                    StringField("swift")
                    StringField("json")
                    StringField("ios")
                }
            }
            Key("details") {
                Json {
                    Key("height") { NumberField(5.9) }
                    Key("weight") { NumberField(160.5) }
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
            Key("matrix") {
                ArrayField {
                    ArrayField {
                        NumberField(1)
                        NumberField(2)
                        NumberField(3)
                    }
                    ArrayField {
                        NumberField(4)
                        NumberField(5)
                        NumberField(6)
                    }
                    ArrayField {
                        NumberField(7)
                        NumberField(8)
                        NumberField(9)
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
            Key("name") { StringField("Alice") }
            Key("middleName") { NullField() }
            Key("age") { NumberField(25) }
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
            Key("isPublic") { BooleanField(true) }
            Key("isArchived") { BooleanField(false) }
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
            Key("integerValue") { NumberField(42) }
            Key("floatValue") { NumberField(3.14) }
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
            Key("users") {
                ArrayField {
                    Json {
                        Key("id") { NumberField(1) }
                        Key("name") { StringField("Bob") }
                        Key("roles") {
                            ArrayField {
                                StringField("admin")
                                StringField("user")
                            }
                        }
                    }
                    Json {
                        Key("id") { NumberField(2) }
                        Key("name") { StringField("Alice") }
                        Key("roles") {
                            ArrayField {
                                StringField("user")
                            }
                        }
                    }
                }
            }
            Key("settings") {
                Json {
                    Key("theme") { StringField("dark") }
                    Key("notifications") {
                        Json {
                            Key("email") { BooleanField(true) }
                            Key("sms") { BooleanField(false) }
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
            Key("emptyObject") { Json {} }
            Key("emptyArray") { ArrayField {} }
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
            Key("event") {
                Json {
                    Key("name") { StringField("Conference") }
                    Key("date") {
                        StringField {
                            let components = DateComponents(
                                timeZone: .gmt, year: 2023, month: 10, day: 15, hour: 9)
                            let calendar = Calendar(identifier: .gregorian)
                            let date = calendar.date(from: components)
                            guard let date else { return nil }
                            let formatter = ISO8601DateFormatter()
                            return formatter.string(from: date)
                        }
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
            Key("largeNumber") { NumberField(1_234_567_890_123_456_789) }
            Key("smallNumber") { NumberField(0.000000000123456) }
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
            Key("data") {
                ArrayField {
                    Json {
                        Key("id") { NumberField(1) }
                        Key("values") {
                            ArrayField {
                                NumberField(1)
                                NumberField(2)
                                NumberField(3)
                            }
                        }
                    }
                    Json {
                        Key("id") { NumberField(2) }
                        Key("values") {
                            ArrayField {
                                NumberField(4)
                                NumberField(5)
                                NumberField(6)
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
            Key("unicode") { StringField("こんにちは世界") }
            Key("emoji") { StringField("😊🎉🚀") }
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
            Key("level1") {
                Json {
                    Key("level2") {
                        Json {
                            Key("level3") {
                                Json {
                                    Key("level4") {
                                        Json { Key("value") { StringField("Deeply nested") } }
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
            Key("mixedArray") {
                ArrayField {
                    NumberField(1)
                    StringField("two")
                    NumberField(3.0)
                    BooleanField(true)
                    NullField()
                    Json {
                        Key("key") { StringField("value") }
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
            Key("largeArray") {
                ArrayField {
                    ArrayField {
                        NumberField(1)
                        NumberField(2)
                        NumberField(3)
                        NumberField(4)
                        NumberField(5)
                    }
                    ArrayField {
                        NumberField(6)
                        NumberField(7)
                        NumberField(8)
                        NumberField(9)
                        NumberField(10)
                    }
                    ArrayField {
                        NumberField(11)
                        NumberField(12)
                        NumberField(13)
                        NumberField(14)
                        NumberField(15)
                    }
                    ArrayField {
                        NumberField(16)
                        NumberField(17)
                        NumberField(18)
                        NumberField(19)
                        NumberField(20)
                    }
                    ArrayField {
                        NumberField(21)
                        NumberField(22)
                        NumberField(23)
                        NumberField(24)
                        NumberField(25)
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
            Key("emptyString") { StringField("") }
            Key("nonEmptyString") { StringField("Hello") }
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
                "escapedString": "This is a \\\\"quoted\\\\" string with \\\\\\\\ backslashes and \\\\n newlines."
        	}
        """
    func escape() -> Json {
        Json {
            Key("message") { StringField("Hello, world! 🌍") }
            Key("specialChars") { StringField("!@#$%^&*()_+{}:\\\"<>?[];',./`~") }
            Key("whitespace") { StringField("   This has leading and trailing spaces   ") }
            Key("newlines") { StringField(#"This\nhas\nnewlines"#) }
            Key("unicodeEscaped") { StringField("\\u0048\\u0065\\u006C\\u006C\\u006F") }
            Key("escapedString") {
                StringField(
                    #"This is a \\"quoted\\" string with \\\\ backslashes and \\n newlines."#)
            }
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
            Key("mixed") {
                Json {
                    Key("string") { StringField("Hello") }
                    Key("number") { NumberField(42) }
                    Key("boolean") { BooleanField(true) }
                    Key("nullValue") { NullField() }
                    Key("array") {
                        ArrayField {
                            NumberField(1)
                            StringField("two")
                            BooleanField(false)
                        }
                    }
                    Key("object") {
                        Json {
                            Key("nestedString") { StringField("World") }
                            Key("nestedNumber") { NumberField(3.14) }
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
            Key("largeString") {
                StringField(
                    "This is a very large string with many characters. It is used to test how well the JSON builder handles large strings. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
                )
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
