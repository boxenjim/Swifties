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
    
    var scheme: String?
    var host: String?
    var path: String?
    
    public init(scheme: String!, host: String!, path: String?) {
        self.scheme = scheme
        self.host = host
        self.path = path
    }
    
    public init(baseURLString: String!) {
        let components = NSURLComponents(string: baseURLString)
        self.scheme = components?.scheme
        self.host = components?.host
        self.path = components?.path
    }
    
    public init(baseURL: NSURL!) {
        let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false)
        self.scheme = components?.scheme
        self.host = components?.host
        self.path = components?.path
    }
    
    private func request(pathComponent: String!, queryItems: [NSURLQueryItem]?) -> NSMutableURLRequest? {
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
        }
        
        return request
    }
    
    private func send(request: NSURLRequest!, delegate: BasicHTTPRequestDelegate?) {
        UIApplication.sharedApplication().pushNetworkActivity()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            delegate!.handleData(data, response: response, error: error, fromRequest: self)
            UIApplication.sharedApplication().popNetworkActivity()
        })
        task.resume()
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
