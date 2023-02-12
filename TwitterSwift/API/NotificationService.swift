//
//  NotificationService.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 12.01.2023.
//

import Foundation
import Firebase

struct NotificationService {
    static let shared = NotificationService()
    let currentUser = Auth.auth().currentUser
    
    func uploadNotification(
        toUser user: User,
        type: NotificationType,
        tweetID: String? = nil
    ) {
        guard let uid = currentUser?.uid else {
            return
        }
        var values: [String: Any] = [
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "uid": uid,
            "type": type.rawValue
        ]
        
        if let tweetID = tweetID {
            values["tweetID"] = tweetID
        }
        REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
    }
    
    func getNotifications(uid: String, completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        REF_NOTIFICATIONS.child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any],
                  let uid = dictionary["uid"] as? String else {
                return
            }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
    
    func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let currentUid = currentUser?.uid else {
            return
        }
        
        let notifications = [Notification]()
        
        REF_NOTIFICATIONS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(notifications)
            } else {
                self.getNotifications(uid: currentUid, completion: completion)
            }
        }
    }
}
