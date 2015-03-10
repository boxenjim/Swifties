//
//  Switchboard.swift
//  Swifties
//
//  Created by Jim Schultz on 3/9/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

public class Switchboard: NSObject {
    public func open(url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if let urlTypes = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleURLTypes") as? NSArray {
            for urlType in urlTypes {
                if let type = urlType as? NSDictionary {
                    if let schemes = type["CFBundleURLSchemes"] as? NSArray {
                        for urlScheme in schemes {
                            if let scheme = urlScheme as? NSString {
                                // do something important here, grab url components etc.
                                let comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
                                println("COMPS: \(comps)")
                                if let queryItems = comps?.queryItems {
                                    for queryItem in queryItems {
                                        if let query = queryItem as? NSURLQueryItem {
                                            println("QUERY: key: \(query.name) value: \(query.value)")
                                        }
                                    }
                                }
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}
