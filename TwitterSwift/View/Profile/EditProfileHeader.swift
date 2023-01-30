//
//  EditProfileHeader.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 30.01.2023.
//

import UIKit

protocol EditProfileHeaderDelegate: AnyObject {
    func didTapChangeProfilePhoto()
}

class EditProfileHeader: UIView {
    // MARK: - Properties
    private let user: User
    weak var delegate: EditProfileHeaderDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        return button
    }()
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        backgroundColor = .twitterBlue
        
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -16)
        let imageSize: CGFloat = 100
        profileImageView.setDimensions(width: imageSize, height: imageSize)
        profileImageView.layer.cornerRadius = imageSize/2
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 8)
        changePhotoButton.addTarget(self, action: #selector(didTapChangePhotoButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func didTapChangePhotoButton() {
        delegate?.didTapChangeProfilePhoto()
    }
}
