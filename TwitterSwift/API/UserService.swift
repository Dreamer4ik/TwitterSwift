//
//  UserService.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 07.12.2022.
//

import Foundation
import Firebase

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
}
