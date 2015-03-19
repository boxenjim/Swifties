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
    
//    func testInitSchemeHostPath() {
//        //https://gamma-api.getblinq.com/v1/products
//        let basicRequest = BasicHTTPRequest(scheme: "https", host: "gamma-api.getblinq.com", path: "/v1/", HTTPHeaders: nil)
//        XCTAssert(basicRequest.scheme == "https", "expected https but got \(basicRequest.scheme)")
//        XCTAssert(basicRequest.host == "gamma-api.getblinq.com", "expected gamma-api.getblinq.com but got \(basicRequest.host)")
//        XCTAssert(basicRequest.path == "/v1/", "expected /v1/ but got \(basicRequest.path)")
//        let request = basicRequest.request("products", queryItems: nil)
//        XCTAssert(request?.URL?.absoluteString == "https://gamma-api.getblinq.com/v1/products", "got \(request?.URL?.absoluteString)")
//        
//        expectation = expectationWithDescription("get products")
//        basicRequest.get("products", queryItems: nil, delegate: self)
//        
//        waitForExpectationsWithTimeout(30, handler: { (error) -> Void in
//            //basicRequest.get("products", queryItems: nil, delegate: self)
//        })
//    }
//    
//    func handleData(data: NSData!, response: NSURLResponse!, error: NSError!, fromRequest: BasicHTTPRequest!) {
//        println("\(response)")
//        expectation?.fulfill()
//    }
    
    func testInitSchemeHostPath() {
        let basicRequest = BasicHTTPRequest(scheme: "testScheme", host: "testHost", path: "testPath", HTTPHeaders: nil)
        XCTAssert(basicRequest.scheme == "testScheme", "expected testScheme but got \(basicRequest.scheme)")
        XCTAssert(basicRequest.host == "testHost", "expected testHost but got \(basicRequest.host)")
        XCTAssert(basicRequest.path == "/testPath", "expected /testPath but got \(basicRequest.path)")
        let request = basicRequest.request("testPathComp", queryItems: nil)
        XCTAssert(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
    func testInitBaseURLString() {
        let basicRequest = BasicHTTPRequest(baseURLString: "testScheme://testHost/testPath", HTTPHeaders: nil)
        XCTAssert(basicRequest.scheme == "testScheme", "expected testScheme but got \(basicRequest.scheme)")
        XCTAssert(basicRequest.host == "testHost", "expected testHost but got \(basicRequest.host)")
        XCTAssert(basicRequest.path == "/testPath", "expected /testPath but got \(basicRequest.path)")
        let request = basicRequest.request("testPathComp", queryItems: nil)
        XCTAssert(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
    func testInitBaseURL() {
        let basicRequest = BasicHTTPRequest(baseURL: NSURL(string: "testScheme://testHost/testPath"), HTTPHeaders: nil)
        XCTAssert(basicRequest.scheme == "testScheme", "expected testScheme but got \(basicRequest.scheme)")
        XCTAssert(basicRequest.host == "testHost", "expected testHost but got \(basicRequest.host)")
        XCTAssert(basicRequest.path == "/testPath", "expected /testPath but got \(basicRequest.path)")
        let request = basicRequest.request("testPathComp", queryItems: nil)
        XCTAssert(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
//    func testConfigureSchemeHostPath() {
//        let basicRequest = BasicHTTPRequest(scheme: "testScheme", host: "testHost", path: "testPath", HTTPHeaders: nil)
//        basicRequest.configure("newTestScheme", host: "newTestHost", path: "newTestPath")
//        XCTAssert(basicRequest.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.scheme)")
//        XCTAssert(basicRequest.host == "newTestHost", "expected newTestHost but got \(basicRequest.host)")
//        XCTAssert(basicRequest.path == "/newTestPath", "expected newTestPath but got \(basicRequest.path)")
//    }
//    
//    func testConfigureBaseURLString() {
//        let basicRequest = BasicHTTPRequest(baseURLString: "newTestScheme://newTestHost/newTestPath", HTTPHeaders: nil)
//        basicRequest.configure("newTestScheme", host: "newTestHost", path: "newTestPath")
//        XCTAssert(basicRequest.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.scheme)")
//        XCTAssert(basicRequest.host == "newTestHost", "expected newTestHost but got \(basicRequest.host)")
//        XCTAssert(basicRequest.path == "/newTestPath", "expected /newTestPath but got \(basicRequest.path)")
//    }
//    
//    func testConfigureBaseURL() {
//        let basicRequest = BasicHTTPRequest(baseURL: NSURL(string: "newTestScheme://newTestHost/newTestPath"), HTTPHeaders: nil)
//        basicRequest.configure("newTestScheme", host: "newTestHost", path: "newTestPath")
//        XCTAssert(basicRequest.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.scheme)")
//        XCTAssert(basicRequest.host == "newTestHost", "expected newTestHost but got \(basicRequest.host)")
//        XCTAssert(basicRequest.path == "/newTestPath", "expected /newTestPath but got \(basicRequest.path)")
//    }

    func testConfigureHeader() {
        // This is an example of a functional test case.
        let basicRequest = BasicHTTPRequest(baseURLString: "https://testing.com", HTTPHeaders: nil)
        let header = ["aTestKey":"aTestValue", "anotherKey":"anotherValue"]
        basicRequest.configure(header)
        XCTAssertNotNil(basicRequest.HTTPHeaderFields["aTestKey"], "should have a value")
        XCTAssertNotNil(basicRequest.HTTPHeaderFields["anotherKey"], "should have a value")
        XCTAssertEqual(basicRequest.HTTPHeaderFields, header, "should be identical, expected: \(header) but got: \(basicRequest.HTTPHeaderFields)")
        let request = basicRequest.request("testPathComp", queryItems: nil)
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
