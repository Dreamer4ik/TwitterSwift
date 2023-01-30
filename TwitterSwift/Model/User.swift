//
//  User.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 07.12.2022.
//

import Foundation
import Firebase

struct User {
    let email: String
    let username: String
    let fullname: String
    var profileImageUrl: URL?
    let uid: String
    var isFollowed = false
    var stats: UserRelationStats?
    var bio: String?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = URL(string: profileImageUrlString)
        }
       
    }
}
