//
//  ProfileViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.12.2022.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var replies = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets:
            return tweets
        case .replies:
            return replies
        case .likes:
            return likedTweets
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
        fetchLikedTweets()
        fetchReplies()
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
            self.collectionView.reloadData()
        }
    }
    
    private func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.replies = tweets
        }
    }
    
    private func fetchLikedTweets() {
        TweetService.shared.fetchLikes(forUser: user) { tweets in
            self.likedTweets = tweets
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
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else {
            return
        }
        collectionView.contentInset.bottom = tabHeight
    }
    
    // MARK: - Actions
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
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
        
        let tweet = currentDataSource[indexPath.row]
        let viewModel = TweetViewModel(tweet: tweet)
        cell.configure(viewModel: viewModel)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = currentDataSource[indexPath.row]
        let vc = TweetViewController(tweet: tweet)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 300
        if let bio = user.bio {
            if bio.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                height += 50
            }
        }
        return CGSize(width: view.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.size(forWidth: view.width, font: .systemFont(ofSize: 15)).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            height += 20
        }
        
        return CGSize(width: view.width, height: height)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileViewController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func didTapEditProfileFollow(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let vc = EditProfileViewController(user: user)
            vc.delegate = self
            let nav = MyNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
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
                    
                    NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
                }
            }
        }
    }
    
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - EditProfileViewControllerDelegate
extension ProfileViewController: EditProfileViewControllerDelegate {
    func handleLogOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch let error {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: EditProfileViewController, wantsToUpdate user: User) {
        self.user = user
        self.collectionView.reloadData()
    }
}

extension ProfileViewController: TweetCollectionViewCellDelegate {
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel) {
        if user.uid != viewModel.user.uid {
            let vc = ProfileViewController(user: viewModel.user)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func handleReplyTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel) {
        if user.uid != viewModel.user.uid {
            let vc = UploadTweetViewController(user: viewModel.user, config: .reply(viewModel.tweet))
            let nav = MyNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCollectionViewCell) {
        guard let tweet = cell.tweet else {
            return
        }
        
        TweetService.shared.likeTweet(tweet: tweet) { err, ref in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: tweet.user, type: .like, tweetID: tweet.tweetID)
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let vc = ProfileViewController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
