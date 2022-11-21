//
//  MainTabBarViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    // MARK: - Properties
    let actionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(actionButton)
        
        let sizeButton: CGFloat = 56
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64,
                            paddingRight: 16, width: sizeButton, height: sizeButton)
        actionButton.layer.cornerRadius = sizeButton/2
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        
    }
    
    private func configureViewControllers() {
        let feed = FeedViewController()
        let explore = ExploreViewController()
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
            let nav = UINavigationController(rootViewController: rootViewController)
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
    
    // MARK: - Actions
    @objc private func didTapActionButton() {
        
    }
}
