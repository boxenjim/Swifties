//
//  LaunchPadTests.swift
//  Swifties
//
//  Created by Jim Schultz on 3/7/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit
import XCTest

class LaunchPadTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAppLaunchURLAndSchemeAreSetOnInit() {
        let appStoreID = "12345678"
        let appURLScheme = "appScheme"
        let launchPad = LaunchPad(appStoreID: appStoreID, appURLScheme: appURLScheme)
        
        XCTAssertEqual(launchPad.appStoreID!, appStoreID, "appStoreID should match, expected \(appStoreID), but got \(launchPad.appStoreID)")
        XCTAssertEqual(launchPad.appURLScheme!, appURLScheme, "appURLScheme should match, expected \(appURLScheme), but got \(launchPad.appURLScheme)")
    }
    
    func testAppLaunchURLAndSchemeAreSetOnConfigure() {
        let appStoreID = "12345678"
        let appURLScheme = "appScheme"
        let launchPad = LaunchPad()
        launchPad.configureLaunchPad(appStoreID, appURLScheme: appURLScheme)
        
        XCTAssertEqual(launchPad.appStoreID!, appStoreID, "appStoreID should match, expected \(appStoreID), but got \(launchPad.appStoreID)")
        XCTAssertEqual(launchPad.appURLScheme!, appURLScheme, "appURLScheme should match, expected \(appURLScheme), but got \(launchPad.appURLScheme)")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
