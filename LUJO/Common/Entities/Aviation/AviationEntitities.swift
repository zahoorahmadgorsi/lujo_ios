import Foundation

struct AVValue: Codable, Equatable {
    let code: String
    let name: String

    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}

struct Pagination: Codable {
    let totalCount: Int
    let pageNumber: Int
    let batchSize: Int
}

struct ResponseMetadata: Codable {
    let errors: [String]
    let warnings: [String]
    let infos: [String]
    let pagination: Pagination
}
