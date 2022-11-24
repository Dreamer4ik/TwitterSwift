//
//  AuthService.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 24.11.2022.
//

import Foundation
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(withCredentials credentials: AuthCredentials,
                      completion: @escaping((Error?, DatabaseReference)-> Void)) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
            
            if let error = error {
                print("Failed to register user with error \(error.localizedDescription)")
                return
            }
            
            guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else {
                return
            }
            
            let filename = NSUUID().uuidString
            let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
            
            storageRef.putData(imageData, metadata: nil) { meta, error in
                storageRef.downloadURL { url, error in
                    guard let profileImageUrl = url?.absoluteString else {
                        return
                    }
                    
                    print("Successfully registered user")
                    
                    guard let uid = result?.user.uid else {
                        return
                    }
                    
                    let values = [
                        "email": credentials.email,
                        "username": credentials.username,
                        "fullname": credentials.fullname,
                        "profileImageUrl": profileImageUrl
                    ] as [String: Any]
                    
                    REF_USERS.child(uid).updateChildValues(values,withCompletionBlock: completion)
                }
            }
        }
    }
}
