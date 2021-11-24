import XCTest

/// The primary class for defining UI test cases in test bundles.
open class XCUITestCase: XCTestCase {
    /// `XCUIApplication` instance that can be used for all UI tests.
    lazy open var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        return app
    }()
}
