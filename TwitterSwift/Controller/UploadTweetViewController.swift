//
//  UploadTweetViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 07.12.2022.
//

import UIKit
import SDWebImage

class UploadTweetViewController: UIViewController {
    
    // MARK: - Properties
    private let user: User
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32/2
        return button
    }()
    
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
    
    private let captionTextView = CaptionTextView()
    
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
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar()
        
        let stack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        stack.spacing = 12
        
        view.addSubview(stack)
        
        
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
    }
    
    private func configureNavigationBar() {
        Utilities.configureNavBar(vc: self)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        actionButton.addTarget(self, action: #selector(didTapTweet), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapTweet() {
        guard let caption = captionTextView.text else {
            return
        }
        TweetService.shared.uploadTweet(caption: caption) { error, ref in
            if let error = error {
                print("Failed to upload tweet with \(error.localizedDescription)")
            }
            
            self.dismiss(animated: true) {
                print("Tweet did upload to database...")
            }
        }
    }
}
