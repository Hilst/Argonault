# Argonaults

This project has the intention to create a JSON builder in swift based on result builders.

This way we can create JSON objects in a more readable way.

Intended to be used for create sample mocks with complex possibilities on a more readable and type safe way.
It also can be used to create JSON objects for tests without have to depend on big String literals or complex dicitionaries.

It's not verified but it's expected that could work on swift pre-build plugins to generate JSON files.

This was not benchmarked against Swift JSONDecoder/Encoder to build JSON from objects. It was not designed to be a replacement for those.

Expected use case is to be used when the codable models are not avaible or to enhance the testability of those methods of JSON parsing.

## Usage

Package.swift

```swift
dependencies: [
    .package(url: "github.com/Hilst/Argonaults", from: "0.1.0")
]
```

Code:

```swift
import Argonaults

let members: [(name: String, age: Int, languages: [String])] = [
    ("Jason", 40, ["Swift", "Objective-C"]),
    ("Orfeu", 20, ["Swift"]),
]

let json = Json {
    "name" <- "Argonaults"
    "members"
        <- ArrayField {
            for member in members {
                Json {
                    "name" <- member.name
                    "age" <- member.age
                    "languages"
                        <- ArrayField {
                            for language in member.languages {
                                Json {
                                    "name" <- language
                                }
                            }
                        }
                    "is_senior" <- member.age > 30 && member.languages.count > 1
                }
            }
        }
}

let asString = json.render(writingOptions: .prettyPrinted)!
print(asString)
```

Output:

```json
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
```

More examples can be found on the unit tests, in specific on [JsonTestCases.swift](./Tests/ArgonaultTests/JsonTestCases.swift) and [ComplexJsonTestCases.swift](./Tests/ArgonaultTests/ComplexJsonTestCases.swift)

## Contact or Contributions

Use the issues to report bugs or suggest improvements.
