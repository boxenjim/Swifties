//
//  Concurrency.swift
//  Swifties
//
//  Created by Jim Schultz on 6/5/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

class Concurrency: NSObject {
    class func synchronize<T>(#lockObj: AnyObject!, closure: ()->T) -> T {
        objc_sync_enter(lockObj)
        var retVal: T = closure()
        objc_sync_exit(lockObj)
        return retVal
    }
}
