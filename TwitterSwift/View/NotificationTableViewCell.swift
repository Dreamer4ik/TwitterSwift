//
//  NotificationTableViewCell.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 13.01.2023.
//

import UIKit

protocol NotificationTableViewCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: NotificationTableViewCell, viewModel: NotificationViewModel)
    func didTapFollow(_ cell: NotificationTableViewCell)
}

class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "NotificationTableViewCell"
    weak var delegate: NotificationTableViewCellDelegate?
    
    private var viewModel: NotificationViewModel?
    
    var notification: Notification? {
        didSet {
            configureFollowButton()
        }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .twitterBlue
        let profileImageSize: CGFloat = 40
        imageView.setDimensions(width: profileImageSize, height: profileImageSize)
        imageView.layer.cornerRadius = profileImageSize/2
        return imageView
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14)
        label.text = "Some test notification message"
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        let stack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
        stack.spacing = 8
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 12)
        
        addSubview(followButton)
        followButton.centerY(inView: self)
        let followButtonHeight: CGFloat = 32
        followButton.setDimensions(width: 92, height: followButtonHeight)
        followButton.layer.cornerRadius = followButtonHeight/2
        followButton.anchor(right: rightAnchor, paddingRight: 12)
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
    }
    
    func configure(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        self.notification = viewModel.notification
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
        
        followButton.isHidden = viewModel.shouldHideFollowButton
        configureFollowButton()
    }
    
    private func configureFollowButton() {
        guard let notification = notification else {
            return
        }
        let viewModel = NotificationViewModel(notification: notification)
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func didTapProfileImage() {
        guard let viewModel = viewModel else {
            return
        }
        delegate?.handleProfileImageTapped(self, viewModel: viewModel)
    }
    
    @objc private func didTapFollowButton() {
        delegate?.didTapFollow(self)
    }
}
