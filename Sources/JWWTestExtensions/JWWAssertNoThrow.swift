import Foundation
import XCTest

public func JWWAssertNoThrow<T>(_ expression: @autoclosure () throws -> T,
                                _ message: String = "",
                                file: StaticString = #file,
                                line: UInt = #line,
                                also validateResult: (T) -> Void) {
    var result: T?
    func executeAndAssignResult(_ expression: @autoclosure () throws -> T, to: inout T?) rethrows {
        to = try expression()
    }

    XCTAssertNoThrow(try executeAndAssignResult(expression(), to: &result), message, file: file, line: line)
    if let r = result {
        validateResult(r)
    }
}

// Via: https://medium.com/@hybridcattt/how-to-test-throwing-code-in-swift-c70a95535ee5
