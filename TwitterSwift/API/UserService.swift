//
//  UserService.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 07.12.2022.
//

import Foundation
import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

struct UserService {
    static let shared = UserService()
    
    let currentUser = Auth.auth().currentUser
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        REF_USERS.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = currentUser?.uid else {
            return
        }
        REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid : 1]) { error, ref in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid : 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = currentUser?.uid else {
            return
        }
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { error, ref in
            REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = currentUser?.uid else {
            return
        }
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping (UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
}
