//
//  FeedViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit
import SDWebImage

class FeedViewController: UIViewController {
    // MARK: - Properties
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(TweetCollectionViewCell.self,
                                forCellWithReuseIdentifier: TweetCollectionViewCell.identifier)
        return collectionView
    }()
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            configureLeftBarItem()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    private func fetchTweets() {
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets
            self.checkIfUserLikedTweets(tweets: tweets)
        }
    }
    
    private func checkIfUserLikedTweets(tweets: [Tweet]) {
        for (index, tweet) in tweets.enumerated() {
            TweetService.shared.checkIfUserLikedTweet(tweet: tweet) { didLike in
                guard didLike == true else {
                    return
                }
                
                self.tweets[index].didLike = true
            }
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.setDimensions(width: 44, height: 44)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    private func configureLeftBarItem() {
        guard let user = user else {
            return
        }
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32/2
        profileImageView.clipsToBounds = true
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    // MARK: - Actions
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TweetCollectionViewCell.identifier,
            for: indexPath
        ) as? TweetCollectionViewCell else {
            preconditionFailure("TweetCollectionViewCell Error")
        }
        
        cell.delegate = self
        let tweet = tweets[indexPath.row]
        let viewModel = TweetViewModel(tweet: tweet)
        cell.configure(viewModel: viewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = tweets[indexPath.row]
        let vc = TweetViewController(tweet: tweet)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.width, font: .systemFont(ofSize: 15)).height
        return CGSize(width: view.width, height: height + 72)
    }
}

extension FeedViewController: TweetCollectionViewCellDelegate {
    func handleLikeTapped(_ cell: TweetCollectionViewCell) {
        guard let tweet = cell.tweet else {
            return
        }
        
        TweetService.shared.likeTweet(tweet: tweet) { err, ref in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
        }
    }
    
    func handleReplyTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel) {
        let vc = UploadTweetViewController(user: viewModel.user, config: .reply(viewModel.tweet))
        let nav = MyNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel) {
        let vc = ProfileViewController(user: viewModel.user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

