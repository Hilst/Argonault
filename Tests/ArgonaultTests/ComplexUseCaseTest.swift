import Testing

@testable import Argonault

struct ComplexUseCase {

    struct Language: Decodable {
        let name: String
        let version: Version
        struct Version: Decodable {
            let major: Int
            let minor: Int
            init(_ major: Int, _ minor: Int) {
                self.major = major
                self.minor = minor
            }
        }
        let frameworks: [Frameworks]
    }
    enum Languages: String, Decodable {
        case swift = "Swift"
        case objectiveC = "Objective-C"
        case kotlin = "Kotlin"
        case java = "Java"

        private var version: Language.Version {
            switch self {
            case .swift:
                return .init(5, 5)
            case .objectiveC:
                return .init(2, 0)
            case .kotlin:
                return .init(1, 5)
            case .java:
                return .init(11, 0)
            }
        }

        private var frameworks: [Frameworks] {
            switch self {
            case .swift:
                return [.uikit, .swiftui]
            case .objectiveC:
                return [.uikit]
            case .kotlin:
                return [.jetpack, .compose]
            case .java:
                return [.jetpack]
            }
        }

        var structured: Language {
            Language(name: rawValue, version: version, frameworks: frameworks)
        }
    }
    enum Frameworks: String, Decodable {
        case uikit = "UIKit"
        case swiftui = "SwiftUI"
        case jetpack = "Jetpack"
        case compose = "Compose"
    }

    struct Worker: Decodable {
        let name: String
        let age: Int
        let isDeveloper: Bool
        let languages: [Languages]?
    }

    let senioriOS = Worker(
        name: "Jason ", age: 1, isDeveloper: true, languages: [.swift, .objectiveC])
    let seniorAndroid = Worker(
        name: "Hercules ", age: 1, isDeveloper: true, languages: [.kotlin, .java])
    let junioriOS = Worker(name: "Orfeu ", age: 1, isDeveloper: true, languages: [.swift])
    let juniorAndroid = Worker(name: "Teseu ", age: 1, isDeveloper: true, languages: [.kotlin])
    let pm = Worker(name: "Heitor ", age: 1, isDeveloper: false, languages: nil)

    struct Company: Decodable {
        let name: String
        let workers: [Worker]
    }

    var argonaults: Company {
        Company(
            name: "Argonault", workers: [senioriOS, seniorAndroid, junioriOS, juniorAndroid, pm])
    }

    var argonaultsJson: String {
        get throws {
            let string = try? """
            {
              "name": "Argonault",
              "workers": [
                {
                  "name": "Jason",
                  "age": 1,
                  "isDeveloper": true,
                  "isSenior": true,
                  "languages": [
                    "Swift",
                    "Objective-C"
                  ]
                },
                {
                  "name": "Hercules",
                  "age": 1,
                  "isDeveloper": true,
                  "isSenior": true,
                  "languages": [
                    "Kotlin",
                    "Java"
                  ]
                },
                {
                  "name": "Orfeu",
                  "age": 1,
                  "isDeveloper": true,
                  "isSenior": false,
                  "languages": [
                    "Swift"
                  ]
                },
                {
                  "name": "Teseu",
                  "age": 1,
                  "isDeveloper": true,
                  "isSenior": false,
                  "languages": [
                    "Kotlin"
                  ]
                },
                {
                  "name": "Heitor",
                  "age": 1,
                  "isDeveloper": false
                }
              ]
            }
            """.formatJson(writeOptions: .prettyPrinted)
            return try #require(string)
        }
    }

    @Test("should build complex use case correctly")
    func complexUseCase() async throws {
        let json = Json {
            JsonKey("name") {
                StringField("Argonault")
            }
            JsonKey("workers") {
                ArrayField {
                    for worker in argonaults.workers {
                        Json {
                            JsonKey("name") {
                                StringField(worker.name)
                            }
                            JsonKey("age") {
                                NumberField(worker.age)
                            }
                            JsonKey("isDeveloper") {
                                BooleanField(worker.isDeveloper)
                            }
                            if worker.isDeveloper {
                                if let firstLanguage = worker.languages?.first {
                                    let isSenior =
                                        (firstLanguage == .swift
                                            && worker.languages?.contains(.objectiveC) ?? false)
                                        || (firstLanguage == .kotlin
                                            && worker.languages?.contains(.java) ?? false)
                                    if firstLanguage == .objectiveC || firstLanguage == .java
                                        || isSenior
                                    {
                                        JsonKey("isSenior") {
                                            BooleanField(true)
                                        }
                                    } else {
                                        JsonKey("isSenior") {
                                            BooleanField(false)
                                        }
                                    }
                                }
                            }
                            if let languages = worker.languages {
                                JsonKey("languages") {
                                    ArrayField {
                                        for language in languages {
                                            StringField(language.rawValue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        let result = try #require(json.render(writingOptions: .prettyPrinted))
        let expected = try #require(argonaultsJson)
        #expect(result == expected)
    }

}
