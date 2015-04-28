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
        let scheme = "testScheme"
        let host = "testHost"
        let path = "testPath"
        let basicRequest = BasicHTTPRequest(scheme: scheme, host: host, path: path, HTTPHeaders: nil)
        XCTAssertTrue(basicRequest.URLComponents?.scheme == scheme, "expected \(scheme) but got \(basicRequest.URLComponents?.scheme)")
        XCTAssertTrue(basicRequest.URLComponents?.host == host, "expected \(host) but got \(basicRequest.URLComponents?.host)")
        XCTAssertTrue(basicRequest.URLComponents?.path == "/\(path)", "expected /\(path) but got \(basicRequest.URLComponents!.path)")
        let request = basicRequest.request(pathComponent: "testPathComp", queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssertTrue(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
    }
    
    func testInitBaseURLString() {
        let basicRequest = BasicHTTPRequest(baseURLString: "testScheme://testHost/testPath", HTTPHeaders: nil)
        XCTAssertTrue(basicRequest.URLComponents?.scheme == "testScheme", "expected testScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssertTrue(basicRequest.URLComponents?.host == "testHost", "expected testHost but got \(basicRequest.URLComponents?.host)")
        XCTAssertTrue(basicRequest.URLComponents?.path == "/testPath", "expected /testPath but got \(basicRequest.URLComponents?.path)")
        let request = basicRequest.request(pathComponent: "testPathComp", queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssertTrue(request?.URL?.absoluteString == "testScheme://testHost/testPath/testPathComp", "got \(request?.URL?.absoluteString)")
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
        let basicRequest = BasicHTTPRequest(scheme: "testScheme", host: "testHost", path: "testPath", HTTPHeaders: nil)
        basicRequest.configure(baseURLString: "newTestScheme://newTestHost/newTestPath")
        XCTAssert(basicRequest.URLComponents?.scheme == "newTestScheme", "expected newTestScheme but got \(basicRequest.URLComponents?.scheme)")
        XCTAssert(basicRequest.URLComponents?.host == "newTestHost", "expected newTestHost but got \(basicRequest.URLComponents?.host)")
        XCTAssert(basicRequest.URLComponents?.path == "/newTestPath", "expected /newTestPath but got \(basicRequest.URLComponents?.path)")
    }
    
    func testConfigureBaseURL() {
        let basicRequest = BasicHTTPRequest(scheme: "testScheme", host: "testHost", path: "testPath", HTTPHeaders: nil)
        basicRequest.configure(baseURL: NSURL(string: "newTestScheme://newTestHost/newTestPath"))
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
        for (key, value) in header {
            XCTAssertNotNil(request?.valueForHTTPHeaderField(key), "should have value:\(value) for key:\(key)")
        }
    }
    
    func testAppendHeaders() {
        let basicRequest = BasicHTTPRequest(baseURLString: "https://testing.com", HTTPHeaders: ["aTestKey":"aTestValue", "anotherKey":"anotherValue"])
        let headers = ["oneMoreKey":"oneMoreValue"]
        let request = basicRequest.request(pathComponent: "newPath", queryItems: nil, headerFields: headers, bodyParams: nil)
        for (key, value) in headers {
            XCTAssertNotNil(request?.valueForHTTPHeaderField(key), "should have value:\(value) for key:\(key)")
        }
    }
    
    func testRequestWithValidPath() {
        let url = NSURL(string: "http://testing.com")
        let basicRequest = BasicHTTPRequest(baseURL: url, HTTPHeaders: nil)
        let request = basicRequest.request(pathComponent: "test", queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssertNotNil(request, "request should not be nil")
        let urlWithPath = url?.URLByAppendingPathComponent("test")
        XCTAssertTrue(urlWithPath?.absoluteString == request?.URL?.absoluteString, "urls should match")
    }
    
    func testRequestWithNilPath() {
        let url = NSURL(string: "http://testing.com")
        let basicRequest = BasicHTTPRequest(baseURL: url, HTTPHeaders: nil)
        let request = basicRequest.request(pathComponent: nil, queryItems: nil, headerFields: nil, bodyParams: nil)
        XCTAssertNotNil(request, "request should not be nil")
        XCTAssertTrue(url?.absoluteString == request?.URL?.absoluteString, "urls should match")
    }

}
