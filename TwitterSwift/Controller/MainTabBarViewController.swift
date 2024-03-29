//
//  MainTabBarViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabBarViewController: UITabBarController {
    
    // MARK: - Properties
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedViewController else { return }
            
            feed.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - API
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    @objc func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            presentLoginController()
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        self.delegate = self
        view.addSubview(actionButton)
        
        let sizeButton: CGFloat = 56
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64,
                            paddingRight: 16, width: sizeButton, height: sizeButton)
        actionButton.layer.cornerRadius = sizeButton/2
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        
    }
    
    private func configureViewControllers() {
        let feed = FeedViewController()
        let explore = ExploreViewController(config: .userSearch)
        let notifications = NotificationsViewController()
        let conversations = ConversationsViewController()
        
        let nav1 = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        let nav2 = templateNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        let nav3 = templateNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notifications)
        let nav4 = templateNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .clear
            tabBar.tintColor = .systemBlue
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            
        } else {
            tabBar.tintColor = .clear
            tabBar.backgroundColor = .systemBlue
        }
        
        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
    }
    
    private func templateNavigationController(
        image: UIImage?,
        rootViewController: UIViewController) -> UINavigationController {
            let nav = MyNavigationController(rootViewController: rootViewController)
            nav.tabBarItem.image = image
            
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                nav.navigationBar.standardAppearance = appearance
                nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
                
            } else {
                nav.navigationBar.barTintColor = .white
            }
            
            return nav
        }
    
    private func presentLoginController() {
        DispatchQueue.main.async {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nav.isModalInPresentation = true
            }
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapActionButton() {
        
        let vc: UIViewController
        
        switch buttonConfig {
        case .tweet:
            guard let user = user else {
                return
            }
            vc = UploadTweetViewController(user: user, config: .tweet)
        case .message:
            vc = ExploreViewController(config: .messages)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let imageName = index == 3 ? "mail" : "new_tweet"
        actionButton.setImage(UIImage(named: imageName), for: .normal)
        buttonConfig = index == 3 ? .message : .tweet
    }
}
