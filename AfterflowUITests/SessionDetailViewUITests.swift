import XCTest

final class SessionDetailViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEditingReflectionPersists() throws {
        let app = self.makeApp()
        app.launch()

        let intention = "Reflection Flow"
        self.createSession(in: app, intention: intention)

        let intentionLabel = app.staticTexts[intention]
        XCTAssertTrue(intentionLabel.waitForExistence(timeout: 3), "Session row should show the intention text")
        intentionLabel.tap()

        let reflectionEditor = app.textViews["reflectionEditor"]
        XCTAssertTrue(reflectionEditor.waitForExistence(timeout: 3), "Reflection editor should appear")
        reflectionEditor.tap()
        reflectionEditor.typeText("Gentle integration notes for testing.")

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button should exist on detail view")
        saveButton.tap()

        let successBanner = app.staticTexts["Reflection saved"]
        XCTAssertTrue(successBanner.waitForExistence(timeout: 2), "Success banner should appear after saving")

        // Navigate back and reopen to ensure persistence
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.waitForExistence(timeout: 2) {
            backButton.tap()
        }
        intentionLabel.tap()
        XCTAssertTrue(reflectionEditor.waitForExistence(timeout: 2))
        XCTAssertTrue((reflectionEditor.value as? String)?.contains("Gentle integration notes") == true)
    }

    // MARK: - Helpers

    private func createSession(in app: XCUIApplication, intention: String) {
        let addSessionButton = app.buttons["addSessionButton"]
        XCTAssertTrue(addSessionButton.waitForExistence(timeout: 5))
        addSessionButton.tap()

        let dosageField = app.textFields["dosageField"]
        XCTAssertTrue(dosageField.waitForExistence(timeout: 3))
        dosageField.tap()
        dosageField.typeText("1g")
        if app.keyboards.buttons["Next"].waitForExistence(timeout: 1) {
            app.keyboards.buttons["Next"].tap()
        }

        let intentionField = app.textFields["intentionField"]
        XCTAssertTrue(intentionField.waitForExistence(timeout: 3))
        intentionField.typeText(intention)

        app.navigationBars["New Session"].buttons["Save"].tap()
    }
}
