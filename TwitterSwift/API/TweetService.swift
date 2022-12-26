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
        
        let ref = REF_TWEETS.childByAutoId()
        
        ref.updateChildValues(values) { err, ref in
            guard let tweetID = ref.key else {
                return
            }
            REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
        }
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any],
                  let uid = dictionary["uid"] as? String else {
                return
            }
            
            let tweetID = snapshot.key
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any],
                      let uid = dictionary["uid"] as? String else {
                    return
                }
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
}
