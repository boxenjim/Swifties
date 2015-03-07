//
//  LaunchPad.swift
//  Swifties
//
//  Created by Jim Schultz on 3/7/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit
import StoreKit

protocol LaunchPadDelegate {
    func launchPadDidLaunchApplication(launchPad: LaunchPad)
    func launchPadDidPresentApplicationAppStorePage(launchPad: LaunchPad)
    func launchPadDidDismissAppStore(launchPad: LaunchPad)
    func launchPadWillBeginPolling(launchPad: LaunchPad)
    func launchPadDidEndPolling(launchPad: LaunchPad, success: Bool)
}

public class LaunchPad: NSObject, SKStoreProductViewControllerDelegate {
    
    var delegate: LaunchPadDelegate?
    var appStoreID: String?
    var appURLScheme: String?
    var polling = false
    
    lazy var appLaunchURL: NSURL? = {
        var launchURL: NSURL? = nil
        if let scheme = self.appURLScheme {
            let comps = NSURLComponents()
            comps.scheme = self.appURLScheme
            launchURL = comps.URL
        }
        return launchURL
    }()
    
    lazy var targetAppInstalled: Bool = {
        if let scheme = self.appURLScheme {
            if let launchURL = self.appLaunchURL {
                return UIApplication.sharedApplication().canOpenURL(launchURL)
            }
        }
        return false
    }()
    
    override init() {
        super.init()
    }
    
    public init(appStoreID: String, appURLScheme: String) {
        super.init()
        self.appStoreID = appStoreID
        self.appURLScheme = appURLScheme
    }
    
    public func configureLaunchPad(appStoreID: String, appURLScheme: String) {
        self.appStoreID = appStoreID
        self.appURLScheme = appURLScheme
    }
    
    // Polling
    func beginPolling(duration: UInt64) {
        if !polling {
            let timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (Int64)(duration * NSEC_PER_SEC))
            dispatch_after(timeoutTime, dispatch_get_main_queue(), { () -> Void in
                self.cancelPolling()
            })
            
            polling = true
            enqueuePoll()
            delegate?.launchPadWillBeginPolling(self)
        }
    }
    
    func enqueuePoll() {
        if polling {
            let popTime = dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC))
            dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                if self.targetAppInstalled {
                    self.launchApp()
                    self.cancelPolling()
                } else {
                    self.enqueuePoll()
                }
            })
        }
    }
    
    public func cancelPolling() {
        polling = false
        delegate?.launchPadDidEndPolling(self, success: targetAppInstalled)
    }
    
    // Launch
    func launchApp() -> Bool {
        if targetAppInstalled {
            delegate?.launchPadDidLaunchApplication(self)
            UIApplication.sharedApplication().openURL(appLaunchURL!)
            return true
        }
        return false
    }
    
    func launchTargetApplicationAppStoreProductPage(fromViewController: UIViewController) {
        if let appID = appStoreID {
            let storeController = SKStoreProductViewController()
            storeController.delegate = self
            
            let appInfo = [SKStoreProductParameterITunesItemIdentifier:appID]
            storeController.loadProductWithParameters(appInfo, completionBlock: { (result, error) -> Void in
                if result {
                    fromViewController.presentViewController(storeController, animated: true, completion: { () -> Void in })
                    self.delegate?.launchPadDidPresentApplicationAppStorePage(self)
                }
            })
        }
    }
    
    public func launchTargetApplication(fromViewController: UIViewController) {
        if !launchApp() {
            launchTargetApplicationAppStoreProductPage(fromViewController)
        }
    }
    
    // SKStoreProductViewControllerDelegate
    public func productViewControllerDidFinish(viewController: SKStoreProductViewController!) {
        beginPolling(300)
        viewController.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in })
        delegate?.launchPadDidDismissAppStore(self)
    }
}
