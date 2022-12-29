//
//  ProfileViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.12.2022.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    private var user: User
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(TweetCollectionViewCell.self,
                                forCellWithReuseIdentifier: TweetCollectionViewCell.identifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeader.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
     override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
     }
    
    // MARK: - API
    
    private func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { tweets in
            self.tweets = tweets
        }
    }
    
    private func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(collectionView)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Actions

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as? ProfileHeader else {
            preconditionFailure("ProfileHeader error")
        }
        
        header.delegate = self
        header.configure(user: user)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TweetCollectionViewCell.identifier,
            for: indexPath
        ) as? TweetCollectionViewCell else {
            preconditionFailure("TweetCollectionViewCell Error")
        }
        
        let tweet = tweets[indexPath.row]
        let viewModel = TweetViewModel(tweet: tweet)
        cell.configure(viewModel: viewModel)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: 120)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileViewController: ProfileHeaderDelegate {
    func didTapEditProfileFollow(_ header: ProfileHeader) {
        if !user.isCurrentUser {
            if user.isFollowed {
                UserService.shared.unfollowUser(uid: user.uid) { ref, error in
                    self.user.isFollowed = false
                    self.collectionView.reloadData()
                }
            } else {
                UserService.shared.followUser(uid: user.uid) { ref, error in
                    self.user.isFollowed = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
