import XCTest

extension XCTestCase {
    func makeApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        var launchArguments = ["-ui-testing"]
        launchArguments.append(contentsOf: arguments)
        app.launchArguments = launchArguments
        return app
    }

    func waitForKeyboardDismissal(in app: XCUIApplication) {
        let keyboard = app.keyboards.firstMatch
        guard keyboard.exists else { return }
        _ = keyboard.waitForExistence(timeout: 1)
        keyboard.swipeDown()
    }
}

extension XCUIElement {
    func waitForHittable(timeout: TimeInterval = 3) {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }

    func scrollTo(element: XCUIElement, maxSwipes: Int = 20) {
        var swipes = 0
        while !element.exists, swipes < maxSwipes {
            self.swipeUp()
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            swipes += 1
        }
    }

    func forceTap() {
        if self.isHittable {
            self.tap()
            return
        }
        if self.exists {
            let center = self.frame.integral.center
            let coord = XCUIApplication().coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: center.x, dy: center.y))
            coord.tap()
        }
    }
}

private extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}
