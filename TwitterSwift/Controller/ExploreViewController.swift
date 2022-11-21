//
//  ExploreViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit

class ExploreViewController: UIViewController {

    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Explore"
    }
    // MARK: - Actions

}
