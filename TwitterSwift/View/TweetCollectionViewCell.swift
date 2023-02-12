//
//  TweetCollectionViewCell.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 21.12.sizeButton22.
//

import UIKit
import ActiveLabel

protocol TweetCollectionViewCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel)
    func handleReplyTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel)
    func handleLikeTapped(_ cell: TweetCollectionViewCell)
    func handleFetchUser(withUsername username: String)
}

class TweetCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "TweetCollectionViewCell"
    weak var delegate: TweetCollectionViewCellDelegate?
    
    private var viewModel: TweetViewModel?
    var tweet: Tweet? {
        didSet {
            configureLikeButton()
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .twitterBlue
        let profileImageSize: CGFloat = 48
        imageView.setDimensions(width: profileImageSize, height: profileImageSize)
        imageView.layer.cornerRadius = profileImageSize/2
        return imageView
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private let commentButton = Utilities.createButtonForTweetCell(withImageName: "comment")
    private let retweetButton = Utilities.createButtonForTweetCell(withImageName: "retweet")
    private let likeButton = Utilities.createButtonForTweetCell(withImageName: "like")
    private let shareButton = Utilities.createButtonForTweetCell(withImageName: "share")
    private let infoLabel = UILabel()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                     paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.spacing = 72
        
        let sizeButton: CGFloat = 20
        commentButton.setDimensions(width: sizeButton, height: sizeButton)
        retweetButton.setDimensions(width: sizeButton, height: sizeButton)
        likeButton.setDimensions(width: sizeButton, height: sizeButton)
        shareButton.setDimensions(width: sizeButton, height: sizeButton)
        
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor,
                             right: rightAnchor, height: 1)
        
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        retweetButton.addTarget(self, action: #selector(didTapRetweet), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configure(viewModel: TweetViewModel) {
        self.viewModel = viewModel
        self.tweet = viewModel.tweet
        captionLabel.text = viewModel.tweet.caption
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    private func configureLikeButton() {
        guard let tweet = tweet else {
            return
        }
        let viewModel = TweetViewModel(tweet: tweet)
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImageName, for: .normal)
    }
    
    private func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapComment() {
        guard let viewModel = viewModel else {
            return
        }
        delegate?.handleReplyTapped(self, viewModel: viewModel)
    }
    
    @objc private func didTapRetweet() {
        print("didTapRetweet")
    }
    
    @objc private func didTapLike() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc private func didTapShare() {
        print("didTapShare")
    }
    
    @objc private func didTapProfileImage() {
        guard let viewModel = viewModel else {
            return
        }
        delegate?.handleProfileImageTapped(self, viewModel: viewModel)
    }
}
