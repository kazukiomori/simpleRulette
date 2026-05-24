//
//  simpleRuletteTests.swift
//  simpleRuletteTests
//
//  Created by Kazuki Omori on 2023/03/15.
//

import XCTest
@testable import simpleRulette

final class simpleRuletteTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSelectedIndexForThreeItemsIncludesUpperBoundary() throws {
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 0, itemCount: 3), 0)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 119.999, itemCount: 3), 0)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 120, itemCount: 3), 1)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 239.999, itemCount: 3), 1)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 240, itemCount: 3), 2)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 359.999, itemCount: 3), 2)
    }

    func testSelectedIndexWrapsAndHandlesUnevenSlices() throws {
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: -0.001, itemCount: 7), 6)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 360, itemCount: 7), 0)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 359.999, itemCount: 7), 6)
        XCTAssertEqual(RuletteViewController.selectedIndex(forDegrees: 360.0 / 7.0, itemCount: 7), 1)
    }

    func testSelectedIndexReturnsNilWhenNoItems() throws {
        XCTAssertNil(RuletteViewController.selectedIndex(forDegrees: 10, itemCount: 0))
    }

}
