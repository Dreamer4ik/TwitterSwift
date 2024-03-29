//
//  TweetHeader.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 03.01.2023.
//

import UIKit
import ActiveLabel

protocol TweetHeaderDelegate: AnyObject {
    func showActionSheet()
    func handleFetchUser(withUsername username: String)
    func handleProfileImageTapped(viewModel: TweetViewModel)
}

class TweetHeader: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "TweetHeader"
    weak var delegate: TweetHeaderDelegate?
    private var viewModel: TweetViewModel?
    
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
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    private let optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        return button
    }()
    
    private let retweetsLabel = UILabel()
    
    private let likesLabel = UILabel()
    
    private let statsView: UIView = {
        let view = UIView()
        
        let divider1 = UIView()
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                       paddingLeft: 8, height: 1)
        
        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor,bottom: view.bottomAnchor, right: view.rightAnchor,
                       paddingLeft: 8, height: 1)
        
        return view
    }()
    
    private let commentButton = Utilities.createButtonForTweetHeader(withImageName: "comment")
    private let retweetButton = Utilities.createButtonForTweetHeader(withImageName: "retweet")
    private let likeButton = Utilities.createButtonForTweetHeader(withImageName: "like")
    private let shareButton = Utilities.createButtonForTweetHeader(withImageName: "share")
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        let labelStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelStack.axis = .vertical
        labelStack.spacing = -6
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, labelStack])
        imageCaptionStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: imageCaptionStack.bottomAnchor, left: leftAnchor, right: rightAnchor,
                            paddingTop: 20, paddingLeft: 16, paddingRight: 16)
        
        addSubview(dateLabel)
        dateLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor,
                         paddingTop: 20, paddingLeft: 16)
        
        addSubview(optionButton)
        optionButton.centerY(inView: imageCaptionStack)
        optionButton.anchor(right: rightAnchor, paddingRight: 8)
        optionButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        
        addSubview(statsView)
        statsView.anchor(top: dateLabel.bottomAnchor, left: leftAnchor,
                         right: rightAnchor, paddingTop: 12, height: 40)
        
        let stackStats = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stackStats.spacing = 12
        
        addSubview(stackStats)
        stackStats.centerY(inView: statsView)
        stackStats.anchor(left: statsView.leftAnchor, paddingLeft: 16)
        
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.spacing = 72
        actionStack.distribution = .fillEqually
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(top: statsView.bottomAnchor, paddingTop: 16)
        
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        retweetButton.addTarget(self, action: #selector(didTapRetweetButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
        
        configureMentionHandler()
    }
    
    func configure(tweet: Tweet) {
        let viewModel = TweetViewModel(tweet: tweet)
        self.viewModel = viewModel
        captionLabel.text = tweet.caption
        fullnameLabel.text = tweet.user.fullname
        usernameLabel.text = viewModel.usernameText
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        dateLabel.text = viewModel.headerTimestamp
        
        retweetsLabel.attributedText = viewModel.retweetsAttributedString
        likesLabel.attributedText = viewModel.likesAttributedString
        
        likeButton.setImage(viewModel.likeButtonImageName, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    private func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapProfileImage() {
        guard let viewModel = viewModel else {
            return
        }
        delegate?.handleProfileImageTapped(viewModel: viewModel)
    }
    
    @objc private func showActionSheet() {
        delegate?.showActionSheet()
    }
    
    @objc private func didTapCommentButton() {
        
    }
    
    @objc private func didTapRetweetButton() {
        
    }
    
    @objc private func didTapLikeButton() {
        
    }
    
    @objc private func didTapShareButton() {
        
    }
}
