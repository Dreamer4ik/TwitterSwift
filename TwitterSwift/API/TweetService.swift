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
    
    func uploadTweet(caption:String, type: UploadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = currentUser?.uid else {
            return
        }
        
        var values = [
            "uid": uid,
            "caption": caption,
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "likes": 0,
            "retweets": 0
        ] as [String: Any]
        
        switch type {
        case .tweet:
            REF_TWEETS.childByAutoId().updateChildValues(values) { err, ref in
                guard let tweetID = ref.key else {
                    return
                }
                REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId().updateChildValues(values) { error, ref in
                guard let replyKey = ref.key else {
                    return
                }
                REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
            }
        }
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        guard let currentUid = currentUser?.uid else {
            return
        }
        
        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
            let followingUid = snapshot.key
            
            REF_USER_TWEETS.child(followingUid).observe(.childAdded) { snapshot in
                let tweetID = snapshot.key
                
                self.fetchTweet(withTweetID: tweetID) { tweet in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        REF_USER_TWEETS.child(currentUid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(Tweet) -> Void) {
        
        REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any],
                  let uid = dictionary["uid"] as? String else {
                return
            }
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var replies = [Tweet]()
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetKey = snapshot.key
            
            guard let replyKey = snapshot.value as? String else {
                return
            }
            
            REF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any],
                      let uid = dictionary["uid"] as? String else {
                    return
                }
                
                let replyID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Tweet(user: user, tweetID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { snapshot in
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
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = currentUser?.uid else {
            return
        }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            // unlike
            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { err, ref in
                REF_TWEET_LIKES.child(tweet.tweetID).child(uid).removeValue(completionBlock: completion)
            }
        } else {
            // like
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { err, ref in
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(tweet: Tweet, completion: @escaping (Bool) -> Void) {
        guard let uid = currentUser?.uid else {
            return
        }
        
        REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
