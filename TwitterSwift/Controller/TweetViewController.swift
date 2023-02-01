//
//  TweetViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 03.01.2023.
//

import UIKit

class TweetViewController: UIViewController {
    
    // MARK: - Properties
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher?
    private var replies = [Tweet]() {
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
        collectionView.register(TweetHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TweetHeader.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchReplies()
    }
    // MARK: - API
    private func fetchReplies() {
        TweetService.shared.fetchReplies(forTweet: tweet) { replies in
            self.replies = replies
        }
    }
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func showActionSheet(user: User) {
        self.actionSheetLauncher = ActionSheetLauncher(user: user)
        self.actionSheetLauncher?.delegate = self
        self.actionSheetLauncher?.show()
    }
    
    // MARK: - Actions
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TweetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TweetCollectionViewCell.identifier,
            for: indexPath
        ) as? TweetCollectionViewCell else {
            preconditionFailure("TweetViewController TweetCollectionViewCell Error")
        }
        
        let reply = replies[indexPath.row]
        let viewModel = TweetViewModel(tweet: reply)
        cell.configure(viewModel: viewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TweetHeader.identifier, for: indexPath) as? TweetHeader else {
            preconditionFailure("TweetHeader error")
        }
        
        header.delegate = self
        header.configure(tweet: tweet)
        
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TweetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweet)
        let height = viewModel.size(forWidth: view.width, font: .systemFont(ofSize: 20)).height
        let increaseHeight: CGFloat = viewModel.tweet.caption.count > 300 ? 120 : 220
        return CGSize(width: view.width, height: height + increaseHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: 120)
    }
}

// MARK: - TweetHeaderDelegate
extension TweetViewController: TweetHeaderDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let vc = ProfileViewController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showActionSheet() {
        if tweet.user.isCurrentUser {
            showActionSheet(user: tweet.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: tweet.user.uid) { isFollowed in
                var user = self.tweet.user
                user.isFollowed = isFollowed
                self.showActionSheet(user: user)
            }
        }
    }
}

extension TweetViewController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { err, ref in
                print("Did follow user \(user.username)")
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                print("Did unfollow user \(user.username)")
            }
        case .report:
            print("")
        case .delete:
            print("")
        }
    }
}
