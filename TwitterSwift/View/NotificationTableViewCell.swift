//
//  NotificationTableViewCell.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 13.01.2023.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "NotificationTableViewCell"
    
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
        
        addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 12, paddingRight: 12)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
        
    }
    
    func configure(viewModel: NotificationViewModel) {
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
    }
    
    // MARK: - Actions
    
    @objc private func didTapProfileImage() {
        //        guard let viewModel = viewModel else {
        //            return
        //        }
        //        delegate?.handleProfileImageTapped(self, viewModel: viewModel)
    }
    
}
