//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Gábor Vass on 07/12/2020.
//

import UserNotifications
import GetSocialNotificationExtension

class NotificationService: UNNotificationServiceExtension {

    var handler: NotificationRequestHandler?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.handler = NotificationRequestHandler()
        self.handler?.handle(request: request, with: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        self.handler?.serviceExtensionTimeWillExpire()
    }

}
