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
    .package(url: "github.com/Hilst/Argonaults", from: "0.0.1")
]
```

Code:

```swift
import Argonaults

let senior = Worker(name: "Jason", age: 40, languages: [.swift, .objectiveC])
let junior = Worker(name: "Orfeu", age: 20, languages: [.swift])
let team = Team(name: "Argonaults", members: [senior, junior])

let json = Json {
        JsonKey("name") { StringField(team.name) }
        JsonKey("members") {
            ArrayField {
                for member in team.members {
                    Json {
                        JsonKey("name") { StringField(member.name) }
                        JsonKey("age") { NumberField(member.age) }
                        JsonKey("languages") {
                            ArrayField {
                                for language in member.languages {
                                    Json {
                                        JsonKey("name") { StringField(language.name) }
                                    }
                                }
                            }
                        }
                        JsonKey("is_senior") { BoolField {
                            member.age > 30 && member.languages.count > 1
                        } }
                    }
                }
            }
        }
    }

print(json.render(.prettyPrinted))
```

Output:

```json
{
  "name": "Argonaults",
  "members": [
    {
      "name": "Jason",
      "age": 40,
      "languages": [{ "name": "swift" }, { "name": "objectiveC" }],
      "is_senior": true
    },
    {
      "name": "Orfeu",
      "age": 20,
      "languages": [{ "name": "swift" }],
      "is_senior": false
    }
  ]
}
```

More examples can be found on the unit tests, in specific on [JsonTestCases.swift](./Tests/ArgonaultTests/JsonTestCases.swift) and [ComplexJsonTestCases.swift](./Tests/ArgonaultTests/ComplexJsonTestCases.swift)

## Contact or Contributions

Use the issues to report bugs or suggest improvements.
