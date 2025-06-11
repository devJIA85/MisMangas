import XCTest
@testable import MisMangas

final class PaginatedResponseTests: XCTestCase {
    func testPaginatedResponseDecoding() throws {
        struct Dummy: Decodable, Equatable {
            let id: Int
            let name: String
        }
        
        let json = """
        {
            "items": [
                { "id": 1, "name": "First" },
                { "id": 2, "name": "Second" }
            ],
            "metadata": {
                "total": 2,
                "page": 1,
                "per": 10
            }
        }
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(PaginatedResponse<Dummy>.self, from: json)
        
        XCTAssertEqual(decoded.data, [Dummy(id: 1, name: "First"), Dummy(id: 2, name: "Second")])
        XCTAssertEqual(decoded.metadata.total, 2)
        XCTAssertEqual(decoded.metadata.page, 1)
        XCTAssertEqual(decoded.metadata.per, 10)
    }
}
