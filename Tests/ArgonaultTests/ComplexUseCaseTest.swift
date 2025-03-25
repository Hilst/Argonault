import Foundation
import Testing

import Argonault

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
        name: "Jason", age: 1, isDeveloper: true, languages: [.swift, .objectiveC])
    let seniorAndroid = Worker(
        name: "Hercules", age: 1, isDeveloper: true, languages: [.kotlin, .java])
    let junioriOS = Worker(name: "Orfeu", age: 1, isDeveloper: true, languages: [.swift])
    let juniorAndroid = Worker(name: "Teseu", age: 1, isDeveloper: true, languages: [.kotlin])
    let pm = Worker(name: "Heitor", age: 1, isDeveloper: false, languages: nil)

    struct Company: Decodable {
        let name: String
        let workers: [Worker]
    }

    var argonaults: Company {
        Company(
            name: "Argonault", workers: [senioriOS, seniorAndroid, junioriOS, juniorAndroid, pm])
    }

    let formattingOptions: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
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
            """.formatJson(writeOptions: formattingOptions)
            return try #require(string)
        }
    }

    @Test("should build complex use case correctly")
    func complexUseCase() async throws {
        let isSenior = { (worker: Worker) -> Bool in
            guard worker.isDeveloper else { return false }
            guard let langs = worker.languages,
                let firstLanguage = langs.first
            else { return false }
            return (firstLanguage == .swift && langs.contains(.objectiveC))
                || (firstLanguage == .kotlin && langs.contains(.java))
        }
        let json = Json {
			"name" <- "Argonault"
			"workers" <- ArrayField {
				for worker in argonaults.workers {
					Json {
						"name" <- worker.name
						"age" <- worker.age
						"isDeveloper" <- worker.isDeveloper
						if worker.isDeveloper {
							"isSenior" <- isSenior(worker)
						}
						if let languages = worker.languages {
							"languages" <- ArrayField { languages.map { $0.rawValue } }
						}
					}
				}
			}
        }
        let result = try #require(json.render(writingOptions: formattingOptions))
        let expected = try #require(argonaultsJson)
        #expect(result == expected)
    }

}
