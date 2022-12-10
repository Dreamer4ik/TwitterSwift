//
//  TweetService.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 10.12.2022.
//

import Firebase

struct TweetService {
    
    static let shared = TweetService()
    let currentUser = Auth.auth().currentUser
    
    func uploadTweet(caption:String, completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let uid = currentUser?.uid else {
            return
        }
        
        let values = [
            "uid": uid,
            "caption": caption,
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "likes": 0,
            "retweets": 0
        ] as [String: Any]
        
        REF_TWEETS.childByAutoId().updateChildValues(values, withCompletionBlock: completion)
    }
}
