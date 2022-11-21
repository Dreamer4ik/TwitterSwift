//
//  FeedViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit

class FeedViewController: UIViewController {
    
    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    // MARK: - Actions
}
