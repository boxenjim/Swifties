//
//  ActivityIndicator.swift
//  Twobr
//
//  Created by Jim Schultz on 2/11/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

var networkActivityKey: Character = "0"

public extension UIApplication {
    
    private var networkActivityCount: Int {
        get {
            return objc_getAssociatedObject(self, &networkActivityKey) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &networkActivityKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    public func pushNetworkActivity() {
        Concurrency.synchronize(lockObj: self) {
            self.networkActivityCount++
        }
        refreshNetworkActivityIndicator()
    }
    
    public func popNetworkActivity() {
        Concurrency.synchronize(lockObj: self) {
            self.networkActivityCount--
        }
        refreshNetworkActivityIndicator()
    }
    
    public func resetNetworkActivity() {
        Concurrency.synchronize(lockObj: self) {
            self.networkActivityCount = 0
        }
        refreshNetworkActivityIndicator()
    }
    
    private func refreshNetworkActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), {
            let active: Bool = self.networkActivityCount > 0
            self.networkActivityIndicatorVisible = active
        })
    }
}
