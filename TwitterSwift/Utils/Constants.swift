//
//  Constants.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 23.11.2022.
//

import Foundation
import Firebase


// MARK: - StorageRefs
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

// MARK: - DatabaseRefs
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
