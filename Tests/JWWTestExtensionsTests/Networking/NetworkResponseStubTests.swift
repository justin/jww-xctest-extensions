import Foundation
import Testing
@testable import JWWTestExtensions

/// Tests to validate the NetworkResponseStub type.
struct NetworkResponseStubTests {
    private let url = URL(string: "https://localhost")!

    @Test
    func successInit() {
        let expectedURL = url
        let expectedCode = 200

        let stub = NetworkResponseStub(url: URL(string: "https://localhost")!, statusCode: 200)
        #expect(stub.url == expectedURL)
        #expect(stub.statusCode == expectedCode)
        #expect(stub.data == nil)
        #expect(stub.error == nil)
    }

    @Test
    func dataInit() {
        let expectedURL = url
        let expectedCode = 200
        let expectedPayload = Data("This is a test payload".utf8)

        let stub = NetworkResponseStub(url: URL(string: "https://localhost")!, statusCode: 200, data: expectedPayload)
        #expect(stub.url == expectedURL)
        #expect(stub.statusCode == expectedCode)
        #expect(stub.data != nil)
        #expect(stub.data == expectedPayload)
        #expect(stub.error == nil)
    }

    @Test
    func errorInit() {
        let expectedURL = url
        let expectedError = URLError(.resourceUnavailable, userInfo: [
            "Test": "Payload"
        ])

        let stub = NetworkResponseStub(url: URL(string: "https://localhost")!, error: expectedError)
        #expect(stub.url == expectedURL)
        #expect(stub.error != nil)
    }

    /// Validate the equality of two stubs.
    @Test
    func equality() {
        let stub1 = NetworkResponseStub(url: url, statusCode: 200)
        let stub2 = NetworkResponseStub(url: url, statusCode: 200)
        let stub3 = NetworkResponseStub(url: URL(string: "https://justinw.me")!, statusCode: 404)
        let stub4 = NetworkResponseStub(url: URL(string: "https://justinw.me")!, error: URLError(.badURL))
        let stub5 = NetworkResponseStub(url: url, statusCode: 400)

        #expect(stub1 == stub2)
        #expect(stub1 != stub3)
        #expect(stub1 != stub4)
        #expect(stub1 != stub5)
    }

    /// Validate we can find the right stub in a collection.
    @Test
    func findingStubByURLRequest() {
        let stub1 = NetworkResponseStub(url: url, statusCode: 200)
        let stub2 = NetworkResponseStub(url: url.appending(queryItems: [ URLQueryItem(name: "test", value: "1,2,3") ]), statusCode: 200)
        let stub3 = NetworkResponseStub(url: url.appending(queryItems: [ URLQueryItem(name: "test", value: "4,5,6") ]), statusCode: 404)

        let collection = [
            stub1,
            stub2,
            stub3
        ]

        let request = URLRequest(url: stub2.url)
        let result = collection.find(for: request)

        #expect(result != nil)
        #expect(result == stub2)
    }
}
