import XCTest

@MainActor
final class SessionListUndoUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDeleteAndUndoFlow() throws {
        let app = self.makeApp()
        app.launch()

        let intention = "Undo Flow"
        self.createSession(in: app, intention: intention)

        let cell = app.cells.containing(.staticText, identifier: intention).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3), "Session cell should exist")
        cell.waitForHittable()

        cell.swipeLeft()
        if app.buttons["Delete"].waitForExistence(timeout: 2) {
            app.buttons["Delete"].tap()
        }

        // Should show confirmation alert
        let confirmationAlert = app.alerts["Delete Session"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 3), "Delete confirmation alert should appear")

        // Confirm deletion
        let confirmButton = confirmationAlert.buttons["confirmDeleteButton"]
        XCTAssertTrue(confirmButton.exists, "Confirm delete button should exist")
        confirmButton.tap()

        let undoButton = app.buttons["undoBannerAction"]
        XCTAssertTrue(undoButton.waitForExistence(timeout: 4), "Undo banner should appear")
        undoButton.tap()

        XCTAssertTrue(cell.waitForExistence(timeout: 6), "Session should reappear after undo")
    }

    func testDeleteConfirmationCancel() throws {
        let app = self.makeApp()
        app.launch()

        let intention = "Cancel Delete"
        self.createSession(in: app, intention: intention)

        let cell = app.cells.containing(.staticText, identifier: intention).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3), "Session cell should exist")
        cell.waitForHittable()

        cell.swipeLeft()
        if app.buttons["Delete"].waitForExistence(timeout: 2) {
            app.buttons["Delete"].tap()
        }

        // Should show confirmation alert
        let confirmationAlert = app.alerts["Delete Session"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 3), "Delete confirmation alert should appear")

        // Cancel deletion
        let cancelButton = confirmationAlert.buttons["cancelDeleteButton"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist")
        cancelButton.tap()

        // Session should still exist
        XCTAssertTrue(cell.exists, "Session should still exist after canceling delete")
        XCTAssertFalse(app.buttons["undoBannerAction"].exists, "Undo banner should not appear when deletion is canceled")
    }

    func testDeleteConfirmationShowsSessionDetails() throws {
        let app = self.makeApp()
        app.launch()

        let intention = "Confirmation Details Test"
        self.createSession(in: app, intention: intention)

        let cell = app.cells.containing(.staticText, identifier: intention).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3), "Session cell should exist")
        cell.waitForHittable()

        cell.swipeLeft()
        if app.buttons["Delete"].waitForExistence(timeout: 2) {
            app.buttons["Delete"].tap()
        }

        // Should show confirmation alert with details
        let confirmationAlert = app.alerts["Delete Session"]
        XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 3), "Delete confirmation alert should appear")

        // Alert should mention treatment type and date
        let alertMessage = confirmationAlert.staticTexts.element(boundBy: 1)
        XCTAssertTrue(alertMessage.exists, "Alert message should exist")

        // Verify both Delete and Cancel buttons exist
        XCTAssertTrue(confirmationAlert.buttons["confirmDeleteButton"].exists, "Confirm button should exist")
        XCTAssertTrue(confirmationAlert.buttons["cancelDeleteButton"].exists, "Cancel button should exist")

        // Dismiss by canceling
        confirmationAlert.buttons["cancelDeleteButton"].tap()
        XCTAssertTrue(confirmationAlert.waitForNonExistence(timeout: 2), "Alert should dismiss")
    }

    func testContextMenuDelete() throws {
        let app = self.makeApp()
        app.launch()

        let intention = "Context Menu Delete"
        self.createSession(in: app, intention: intention)

        let cell = app.cells.containing(.staticText, identifier: intention).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3), "Session cell should exist")
        cell.waitForHittable()

        // Long press to show context menu
        cell.press(forDuration: 1.0)

        // Wait for context menu to appear
        let deleteMenuItem = app.menuItems["Delete"]
        if deleteMenuItem.waitForExistence(timeout: 2) {
            deleteMenuItem.tap()

            // Should show confirmation alert
            let confirmationAlert = app.alerts["Delete Session"]
            XCTAssertTrue(confirmationAlert.waitForExistence(timeout: 3), "Delete confirmation alert should appear from context menu")

            // Confirm deletion
            confirmationAlert.buttons["confirmDeleteButton"].tap()

            // Verify undo banner appears
            let undoButton = app.buttons["undoBannerAction"]
            XCTAssertTrue(undoButton.waitForExistence(timeout: 4), "Undo banner should appear")
        }
    }

    private func createSession(in app: XCUIApplication, intention: String) {
        let addSessionButton = app.buttons["addSessionButton"]
        XCTAssertTrue(addSessionButton.waitForExistence(timeout: 5))
        addSessionButton.tap()

        guard let intentionField = app.waitForTextInput("intentionField") else {
            XCTFail("Intention field should exist")
            return
        }
        intentionField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 2))
        intentionField.typeText(intention)

        app.navigationBars["New Session"].buttons["Save"].tap()
        if app.buttons["None"].waitForExistence(timeout: 1) {
            app.buttons["None"].tap()
        }
        let rootAddButton = app.buttons["addSessionButton"]
        XCTAssertTrue(rootAddButton.waitForExistence(timeout: 5), "Main list should return after saving")
        rootAddButton.waitForHittable()
        let list = app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch : app.tables.firstMatch
        let cell = app.cells.containing(.staticText, identifier: intention).firstMatch
        if list.exists {
            list.scrollTo(element: cell)
        }
    }
}
