//
//  BasicHTTPRequest.swift
//  Swifties
//
//  Created by Jim Schultz on 3/16/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

public class BasicHTTPRequest: NSObject {
    var URLComponents: NSURLComponents? = nil
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
    
    
    
    public override init() {
        super.init()
    }
    
    public convenience init(scheme: String!, host: String!, path: String?, HTTPHeaders: [String:String]?) {
        self.init()
        configure(scheme, host: host, path: path)
        if let headers = HTTPHeaders {
            configure(HTTPHeaders: headers)
        }
    }
    
    public convenience init(baseURLString: String!, HTTPHeaders: [String:String]?) {
        self.init()
        configure(baseURLString: baseURLString)
        if let headers = HTTPHeaders {
            configure(HTTPHeaders: headers)
        }
    }
    
    public convenience init(baseURL: NSURL!, HTTPHeaders: [String:String]?) {
        self.init()
        configure(baseURL: baseURL)
        if let headers = HTTPHeaders {
            configure(HTTPHeaders: headers)
        }
    }
    
    
    
    public func configure(scheme: String!, host: String!, path: String?) {
        URLComponents = NSURLComponents()
        URLComponents?.scheme = scheme
        URLComponents?.host = host
        URLComponents?.path = path
    }
    
    public func configure(#baseURLString: String!) {
        URLComponents = NSURLComponents(string: baseURLString)
    }
    
    public func configure(#baseURL: NSURL!) {
        URLComponents = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false)
    }
    
    public func configure(#HTTPHeaders: [String:String]) {
        for (key, value) in HTTPHeaders {
            HTTPHeaderFields[key] = value
        }
    }
    
    
    
    public func request(url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:AnyObject]?) -> NSMutableURLRequest? {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        
        if let query = queryItems {
            components?.queryItems = query
        }
        
        if var url = components?.URL {
            let request = NSMutableURLRequest(URL: url)
            if let headers = headerFields {
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            if let body = bodyParams {
                var error: NSError? = nil
                if let bodyJSON: NSData = NSJSONSerialization.dataWithJSONObject(body, options: .allZeros, error: &error) {
                    request.HTTPBody = bodyJSON
                }
            }
            
            return request
        }
        return nil
    }
    
    public func request(#pathComponent: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:AnyObject]?) -> NSMutableURLRequest? {
        
        if var url = URLComponents?.URL {
            url = url.URLByAppendingPathComponent(pathComponent)
            var headers = HTTPHeaderFields
            if let heads = headerFields {
                for (key, value) in headers {
                    headers[key] = value
                }
            }
            return request(url, queryItems: queryItems, headerFields: headers, bodyParams: bodyParams)
        }
        
        return nil
    }
    
    public func request(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:AnyObject]?) -> NSMutableURLRequest? {
        return request(NSURL(string: urlString), queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams)
    }
    
    
    
    public func send(request: NSURLRequest!, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        UIApplication.sharedApplication().pushNetworkActivity()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            completion(data: jsonData, response: response, error: error, request: self)
            UIApplication.sharedApplication().popNetworkActivity()
        })
        task.resume()
    }
    
    public func send(#pathComponent: String!, httpMethod: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        if let request = request(pathComponent: pathComponent, queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams) {
            request.HTTPMethod = httpMethod
            send(request, completion: completion)
        }
    }
    
    public func send(#urlString: String!, httpMethod: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        if let request = request(urlString: urlString, queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams) {
            request.HTTPMethod = httpMethod
            send(request, completion: completion)
        }
    }
    
    public func send(url: NSURL!, httpMethod: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        if let request = request(url, queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams) {
            request.HTTPMethod = httpMethod
            send(request, completion: completion)
        }
    }
    
    
    
    public func get(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        send(urlString: urlString, httpMethod: "GET", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completion: completion)
    }
    
    public func get(#url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        send(url, httpMethod: "GET", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completion: completion)
    }
    
    public func get(#pathComponent: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        send(pathComponent: pathComponent, httpMethod: "GET", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completion: completion)
    }
    
    public func get(#urlString: String!, queryItems: [NSURLQueryItem]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        get(urlString: urlString, queryItems: queryItems, headerFields: nil, bodyParams: nil, completion: completion)
    }
    
    public func get(#url: NSURL!, queryItems: [NSURLQueryItem]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        get(url: url, queryItems: queryItems, headerFields: nil, bodyParams: nil, completion: completion)
    }
    
    public func get(#pathComponent: String!, queryItems: [NSURLQueryItem]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        get(pathComponent: pathComponent, queryItems: queryItems, headerFields: nil, bodyParams: nil, completion: completion)
    }
    
    
    
    public func post(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        send(urlString: urlString, httpMethod: "POST", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completion: completion)
    }
    
    public func post(#url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        send(url, httpMethod: "POST", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completion: completion)
    }
    
    public func post(#pathComponent: String!, queryItems: [NSURLQueryItem]?, headerFields: [String:String]?, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        send(pathComponent: pathComponent, httpMethod: "POST", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completion: completion)
    }
    
    public func post(#urlString: String!, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        post(urlString: urlString, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completion: completion)
    }
    public func post(#url: NSURL!, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        post(url: url, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completion: completion)
    }
    public func post(#pathComponent: String!, bodyParams: [String:String]?, completion: (data: AnyObject!, response: NSURLResponse!, error: NSError!, request: BasicHTTPRequest!) -> Void) {
        post(pathComponent: pathComponent, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completion: completion)
    }
}
