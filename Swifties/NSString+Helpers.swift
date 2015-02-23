//
//  NSString+Helpers.swift
//  Swifties
//
//  Created by Jim Schultz on 2/23/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

public extension NSString {
    
    func substringBetween(string: String, otherString: String) -> String? {
        let startRange = self.rangeOfString(string, options: .CaseInsensitiveSearch)
        if startRange.location != NSNotFound {
            
            let loc = startRange.location + startRange.length
            let len = self.length - loc
            var targetRange = NSMakeRange(loc, len)
            let endRange = rangeOfString(otherString, options: NSStringCompareOptions.CaseInsensitiveSearch, range: targetRange)
            
            if endRange.location != NSNotFound {
                targetRange.length = endRange.location - targetRange.location;
                return substringWithRange(targetRange)
            }
        }
        return nil
    }
    
}
