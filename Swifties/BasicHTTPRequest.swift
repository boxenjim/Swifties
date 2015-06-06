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
    
    private func append(headerFields: [String: String]?) -> [String: String]? {
        var headers = HTTPHeaderFields
        if let heads = headerFields{
            for (key, value) in heads {
                headers[key] = value
            }
        }
        return headers
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(scheme: String!, host: String!, path: String?, port: Int?, HTTPHeaders: [String: String]?) {
        self.init()
        configure(scheme, host: host, path: path, port: port)
        if let headers = HTTPHeaders {
            configure(HTTPHeaders: headers)
        }
    }
    
    public convenience init(baseURLString: String!, HTTPHeaders: [String: String]?) {
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
    
    
    
    public func configure(scheme: String!, host: String!, path: String?, port: Int?) {
        URLComponents = NSURLComponents()
        URLComponents?.scheme = scheme
        URLComponents?.host = host
        URLComponents?.path = self.check(path)
        URLComponents?.port = port
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
    
    
    
    public func request(url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?) -> NSMutableURLRequest? {
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
            
            if let body: AnyObject = bodyParams {
                var error: NSError? = nil
                if let bodyJSON: NSData = NSJSONSerialization.dataWithJSONObject(body, options: .allZeros, error: &error) {
                    request.HTTPBody = bodyJSON
                }
            }
            
            return request
        }
        return nil
    }
    
    public func request(#pathComponent: String?, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?) -> NSMutableURLRequest? {
        
        if var url = URLComponents?.URL {
            if let path = pathComponent {
                url = url.URLByAppendingPathComponent(path)
            }
            return request(url, queryItems: queryItems, headerFields: append(headerFields), bodyParams: bodyParams)
        }
        
        return nil
    }
    
    public func request(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?) -> NSMutableURLRequest? {
        return request(NSURL(string: urlString), queryItems: queryItems, headerFields: append(headerFields), bodyParams: bodyParams)
    }
    
    public func dataTask(request: NSURLRequest!, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler?(json, response, error)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler?(data, response, error)
                })
            }
            UIApplication.sharedApplication().popNetworkActivity(closure: nil)
        })
        return task
    }
    
    public func send(request: NSURLRequest!, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        UIApplication.sharedApplication().pushNetworkActivity(closure: nil)
        let task = dataTask(request, completionHandler: completionHandler)
        task?.resume()
        return task
    }
    
    public func send(#pathComponent: String?, httpMethod: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        if let request = request(pathComponent: pathComponent, queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams) {
            request.HTTPMethod = httpMethod
            return send(request, completionHandler: completionHandler)
        }
        return nil
    }
    
    public func send(#urlString: String!, httpMethod: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        if let request = request(urlString: urlString, queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams) {
            request.HTTPMethod = httpMethod
            return send(request, completionHandler: completionHandler)
        }
        return nil
    }
    
    public func send(url: NSURL!, httpMethod: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        if let request = request(url, queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams) {
            request.HTTPMethod = httpMethod
            return send(request, completionHandler: completionHandler)
        }
        return nil
    }
    
    
    
    public func get(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: [[String:AnyObject]]?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(urlString: urlString, httpMethod: "GET", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func get(#url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(url, httpMethod: "GET", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func get(#pathComponent: String?, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(pathComponent: pathComponent, httpMethod: "GET", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func get(#urlString: String!, queryItems: [NSURLQueryItem]?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return get(urlString: urlString, queryItems: queryItems, headerFields: nil, bodyParams: nil, completionHandler: completionHandler)
    }
    
    public func get(#url: NSURL!, queryItems: [NSURLQueryItem]?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return get(url: url, queryItems: queryItems, headerFields: nil, bodyParams: nil, completionHandler: completionHandler)
    }
    
    public func get(#pathComponent: String?, queryItems: [NSURLQueryItem]?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return get(pathComponent: pathComponent, queryItems: queryItems, headerFields: nil, bodyParams: nil, completionHandler: completionHandler)
    }
    
    
    
    public func post(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(urlString: urlString, httpMethod: "POST", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func post(#url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(url, httpMethod: "POST", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func post(#pathComponent: String?, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(pathComponent: pathComponent, httpMethod: "POST", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func post(#urlString: String!, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return post(urlString: urlString, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    public func post(#url: NSURL!, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return post(url: url, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    public func post(#pathComponent: String?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return post(pathComponent: pathComponent, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    
    public func put(#urlString: String!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(urlString: urlString, httpMethod: "PUT", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func put(#url: NSURL!, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(url, httpMethod: "PUT", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func put(#pathComponent: String?, queryItems: [NSURLQueryItem]?, headerFields: [String: String]?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return send(pathComponent: pathComponent, httpMethod: "PUT", queryItems: queryItems, headerFields: headerFields, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    
    public func put(#urlString: String!, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return put(urlString: urlString, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    public func put(#url: NSURL!, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return put(url: url, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completionHandler: completionHandler)
    }
    public func put(#pathComponent: String?, bodyParams: AnyObject?, completionHandler: ((AnyObject!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask? {
        return put(pathComponent: pathComponent, queryItems: nil, headerFields: nil, bodyParams: bodyParams, completionHandler: completionHandler)
    }
}
