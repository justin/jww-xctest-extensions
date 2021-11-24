import Foundation

public struct UITestTimeout {
    /// The default amount of time to wait for an expectation to time out.
    public static let unitTestExpectation: TimeInterval = 2.0

    /// The default amount of time to wait for an item to appear on screen during a UI test.
    public static let uiTestExpectation: TimeInterval = 10.0

    private init() { }
}
