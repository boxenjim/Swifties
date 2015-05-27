//
//  UIApplication+Helpers.swift
//  Swifties
//
//  Created by Jim Schultz on 5/26/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import UIKit

public extension UIApplication {
    public func configureNotifications() {
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        self.registerUserNotificationSettings(settings)
        self.registerForRemoteNotifications()
    }
}
