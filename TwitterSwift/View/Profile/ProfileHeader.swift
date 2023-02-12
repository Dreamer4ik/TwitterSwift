//
//  ProfileHeader.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.12.2022.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func didTapBack()
    func didTapEditProfileFollow(_ header: ProfileHeader)
    func didSelect(filter: ProfileFilterOptions)
}

class ProfileHeader: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "ProfileHeader"
    weak var delegate: ProfileHeaderDelegate?
    
    private let filterBar = ProfileFilterView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_white_24dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        return imageView
    }()
    
    private let editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        return button
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
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 3
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helpers
    private func configureUI() {
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(backButton)
        backButton.anchor(top: containerView.topAnchor, left: containerView.leftAnchor,
                          paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor,
                                paddingTop: -24, paddingLeft: 8)
        let sizeProfileImage: CGFloat = 80
        profileImageView.setDimensions(width: sizeProfileImage, height: sizeProfileImage)
        profileImageView.layer.cornerRadius = sizeProfileImage/2
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor, right: rightAnchor,
                                       paddingTop: 12, paddingRight: 12)
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36/2
        editProfileFollowButton.addTarget(self, action: #selector(didTapEditProfileFollowButton), for: .touchUpInside)
        
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                              usernameLabel,
                                                              bioLabel])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(didTapFollowLabel))
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followTap)
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(didTapFollowersLabel))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followerTap)
        
        addSubview(followStack)
        followStack.anchor(top: userDetailsStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
    }
    
    func configure(user: User) {
        let viewModel = ProfileHeaderViewModel(user: user)
        
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
        bioLabel.text = user.bio
        
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        profileImageView.sd_setImage(with: user.profileImageUrl)
        followersLabel.attributedText = viewModel.followersString
        followingLabel.attributedText = viewModel.followingString
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        delegate?.didTapBack()
    }
    
    @objc private func didTapEditProfileFollowButton() {
        delegate?.didTapEditProfileFollow(self)
    }
    
    @objc private func didTapFollowLabel() {
        
    }
    
    @objc private func didTapFollowersLabel() {
        
    }
}

// MARK: - ProfileFilterViewDelegate
extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFilterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else { return }
        delegate?.didSelect(filter: filter)
    }
}
