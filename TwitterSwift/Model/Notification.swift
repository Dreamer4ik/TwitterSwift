//
//  Notification.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 12.01.2023.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    let tweetID: String?
    var timestamp: Date?
    let user: User
    var tweet: Tweet?
    var type: NotificationType?
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        
        self.tweetID = dictionary["timestamp"] as? String ?? ""
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
