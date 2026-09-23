//
//  ScreenshotUITests.swift
//  simpleRuletteUITests
//

import XCTest

final class ScreenshotUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func tapWhenHittable(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6) {
        XCTAssertTrue(element.waitForExistence(timeout: 30))
        var attempts = 0
        while !element.isHittable && attempts < maxSwipes {
            app.swipeUp()
            usleep(300_000)
            attempts += 1
        }
        XCTAssertTrue(element.isHittable, "element not hittable after scrolling")
        element.tap()
    }

    func test01_HomeScreen() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(1)
        attach(app, name: "01_home")
    }

    func test02_WeightSettings() throws {
        let app = XCUIApplication()
        app.launch()
        let editButton = app.buttons["editItemsButton"]
        tapWhenHittable(editButton, in: app)

        let weightRow = app.buttons["重さ（当選確率）を設定"]
        tapWhenHittable(weightRow, in: app)

        let weightScreenTitle = app.staticTexts["重さを設定"]
        XCTAssertTrue(weightScreenTitle.waitForExistence(timeout: 10))
        sleep(1)
        attach(app, name: "02_weight_settings")
    }

    func test03_RiggedMode() throws {
        let app = XCUIApplication()
        app.launch()
        let editButton = app.buttons["editItemsButton"]
        tapWhenHittable(editButton, in: app)

        let riggedRow = app.buttons["演出モードを設定"]
        tapWhenHittable(riggedRow, in: app)

        let itemButton = app.buttons["ラーメン"]
        tapWhenHittable(itemButton, in: app)
        sleep(1)
        attach(app, name: "03_rigged_mode")
    }
}
