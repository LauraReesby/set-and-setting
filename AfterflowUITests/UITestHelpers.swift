import XCTest

extension XCTestCase {
    func makeApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        var launchArguments = ["-ui-testing"]
        launchArguments.append(contentsOf: arguments)
        app.launchArguments = launchArguments
        return app
    }
}
