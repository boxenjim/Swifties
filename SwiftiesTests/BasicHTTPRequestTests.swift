//
//  BasicHTTPRequestTests.swift
//  Swifties
//
//  Created by Jim Schultz on 3/19/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit
import XCTest

class BasicHTTPRequestTests: XCTestCase {

    var expectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitSchemeHostPath() {
        let basicRequest = BasicHTTPRequest(scheme: "testScheme", host: "testHost", path: "testPath", HTTPHeaders: nil)
        XCTAssert(basicRequest.URLComponents?.scheme == "testScheme", "expected testScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "testHost", "expected testHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/testPath", "expected /testPath but got \(basicRequest.URLComponents?.path)")
        let request = basicRequest.request(urlString: "testPathComp", queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssert(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
    func testInitBaseURLString() {
        let basicRequest = BasicHTTPRequest(baseURLString: "testScheme://testHost/testPath", HTTPHeaders: nil)
        XCTAssert(basicRequest.URLComponents?.scheme == "testScheme", "expected testScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "testHost", "expected testHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/testPath", "expected /testPath but got \(basicRequest.URLComponents?.path)")
        let request = basicRequest.request(pathComponent: "testPathComp", queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssert(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
    func testInitBaseURL() {
        let basicRequest = BasicHTTPRequest(baseURL: NSURL(string: "testScheme://testHost/testPath"), HTTPHeaders: nil)
        XCTAssert(basicRequest.URLComponents?.scheme == "testScheme", "expected testScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "testHost", "expected testHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/testPath", "expected /testPath but got \(basicRequest.URLComponents?.path)")
        let request = basicRequest.request(pathComponent: "testPathComp", queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssert(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
    func testConfigureSchemeHostPath() {
        let basicRequest = BasicHTTPRequest(scheme: "testScheme", host: "testHost", path: "testPath", HTTPHeaders: nil)
        basicRequest.configure("newTestScheme", host: "newTestHost", path: "newTestPath")
        XCTAssert(basicRequest.URLComponents?.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "newTestHost", "expected newTestHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/newTestPath", "expected newTestPath but got \(basicRequest.URLComponents?.path)")
    }
    
    func testConfigureBaseURLString() {
        let basicRequest = BasicHTTPRequest(baseURLString: "newTestScheme://newTestHost/newTestPath", HTTPHeaders: nil)
        basicRequest.configure("newTestScheme", host: "newTestHost", path: "newTestPath")
        XCTAssert(basicRequest.URLComponents?.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "newTestHost", "expected newTestHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/newTestPath", "expected /newTestPath but got \(basicRequest.URLComponents?.path)")
    }
    
    func testConfigureBaseURL() {
        let basicRequest = BasicHTTPRequest(baseURL: NSURL(string: "newTestScheme://newTestHost/newTestPath"), HTTPHeaders: nil)
        basicRequest.configure("newTestScheme", host: "newTestHost", path: "newTestPath")
        XCTAssert(basicRequest.URLComponents?.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "newTestHost", "expected newTestHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/newTestPath", "expected /newTestPath but got \(basicRequest.URLComponents?.path)")
    }

    func testConfigureHeader() {
        // This is an example of a functional test case.
        let basicRequest = BasicHTTPRequest(baseURLString: "https://testing.com", HTTPHeaders: nil)
        let header = ["aTestKey":"aTestValue", "anotherKey":"anotherValue"]
        basicRequest.configure(HTTPHeaders: header)
        XCTAssertNotNil(basicRequest.HTTPHeaderFields["aTestKey"], "should have a value")
        XCTAssertNotNil(basicRequest.HTTPHeaderFields["anotherKey"], "should have a value")
        XCTAssertEqual(basicRequest.HTTPHeaderFields, header, "should be identical, expected: \(header) but got: \(basicRequest.HTTPHeaderFields)")
        let request = basicRequest.request(pathComponent: "testPathComp", queryItems: nil, headerFields: nil, bodyParams: nil)
        let headers = request?.allHTTPHeaderFields
        for (key, value) in header {
            XCTAssertNotNil(request?.valueForHTTPHeaderField(key), "should have value:\(value) for key:\(key)")
        }
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
