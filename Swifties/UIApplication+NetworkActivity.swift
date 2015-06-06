//
//  ActivityIndicator.swift
//  Twobr
//
//  Created by Jim Schultz on 2/11/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

var networkActivityCount: Int = 0

public extension UIApplication {
    
    private func count() -> Int {
        return Concurrency.synchronize(lockObj: self) {
            return networkActivityCount
        }
    }
    
    public func pushNetworkActivity(#closure: (() -> Void)?) {
        Concurrency.synchronize(lockObj: self) {
            networkActivityCount++
        }
        refreshNetworkActivityIndicator()
        closure?()
    }
    
    public func popNetworkActivity(#closure: (() -> Void)?) {
        Concurrency.synchronize(lockObj: self) {
            networkActivityCount--
        }
        refreshNetworkActivityIndicator()
        closure?()
    }
    
    public func resetNetworkActivity(#closure: (() -> Void)?) {
        Concurrency.synchronize(lockObj: self) {
            networkActivityCount = 0
        }
        refreshNetworkActivityIndicator()
        closure?()
    }
    
    func refreshNetworkActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), {
            let active: Bool = networkActivityCount > 0
            self.networkActivityIndicatorVisible = active
        })
    }
}
