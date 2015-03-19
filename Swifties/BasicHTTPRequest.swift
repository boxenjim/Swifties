//
//  APIRequest.swift
//  Swifties
//
//  Created by Jim Schultz on 3/16/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

public protocol BasicHTTPRequestDelegate {
    func handleData(data: NSData!, response: NSURLResponse!, error: NSError!, fromRequest: BasicHTTPRequest!)
}

public class BasicHTTPRequest: NSObject {
    
    var scheme: String? = nil
    var host: String? = nil
    var path: String? = nil
    var HTTPHeaderFields: [String:String] = [:]
    
    private func check(path: String?) -> String? {
        if var p = path {
            if !p.hasPrefix("/") {
                p = "/\(p)"
            }
            return p
        }
        return nil
    }
    
    public init(scheme: String!, host: String!, path: String?) {
        super.init()
        self.scheme = scheme
        self.host = host
        self.path = check(path)
    }
    
    public init(baseURLString: String!) {
        super.init()
        let components = NSURLComponents(string: baseURLString)
        scheme = components?.scheme
        host = components?.host
        path = components?.path
    }
    
    public init(baseURL: NSURL!) {
        super.init()
        let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false)
        scheme = components?.scheme
        host = components?.host
        path = components?.path
    }
    
    public func request(pathComponent: String!, queryItems: [NSURLQueryItem]?) -> NSMutableURLRequest? {
        let components = NSURLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        if let query = queryItems {
            components.queryItems = query
        }
        
        var request: NSMutableURLRequest? = nil
        
        if var url = components.URL {
            url = url.URLByAppendingPathComponent(pathComponent)
            request = NSMutableURLRequest(URL: url)
            request?.allHTTPHeaderFields = HTTPHeaderFields
        }
        
        return request
    }
    
    public func send(request: NSURLRequest!, delegate: BasicHTTPRequestDelegate?) {
        UIApplication.sharedApplication().pushNetworkActivity()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            delegate!.handleData(data, response: response, error: error, fromRequest: self)
            UIApplication.sharedApplication().popNetworkActivity()
        })
        task.resume()
    }
    
    public func configure(scheme: String!, host: String!, path: String?) {
        self.scheme = scheme
        self.host = host
        self.path = check(path)
    }
    
    public func configure(baseURLString: String!) {
        let comps = NSURLComponents(string: baseURLString)
        scheme = comps?.scheme
        host = comps?.host
        path = comps?.path
    }
    
    public func configure(baseURL: NSURL!) {
        let comps = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false)
        scheme = comps?.scheme
        host = comps?.host
        path = comps?.path
    }
    
    public func configure(HTTPHeaders: [String:String]) {
        for (key, value) in HTTPHeaders {
            HTTPHeaderFields[key] = value
        }
    }
    
    public func get(pathComponent: String!, queryItems: [NSURLQueryItem]?, delegate: BasicHTTPRequestDelegate?) {
        if let request = request(pathComponent, queryItems: queryItems) {
            request.HTTPMethod = "GET"
            send(request, delegate: delegate)
        }
    }
    
    public func post(pathComponent: String!, queryItems: [NSURLQueryItem]?, httpBodyParams: [String:String]?, delegate: BasicHTTPRequestDelegate?) {
        
    }
}
