//
//  TweetCollectionViewCell.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 21.12.sizeButton22.
//

import UIKit

protocol TweetCollectionViewCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell, viewModel: TweetViewModel)
}

class TweetCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "TweetCollectionViewCell"
    weak var delegate: TweetCollectionViewCellDelegate?
    
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
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    private let retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    private let infoLabel = UILabel()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 8, paddingLeft: 8)
        let stack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
        
        addSubview(stack)
        stack.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor,
                     right: rightAnchor, paddingLeft: 12, paddingRight: 12)
        
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configure(viewModel: TweetViewModel) {
        self.viewModel = viewModel
        captionLabel.text = viewModel.tweet.caption
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
    }
    
    // MARK: - Actions
    @objc private func didTapComment() {
        print("didTapComment")
    }
    
    @objc private func didTapRetweet() {
        print("didTapRetweet")
    }
    
    @objc private func didTapLike() {
        print("didTapLike")
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
