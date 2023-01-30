//
//  EditProfileViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 30.01.2023.
//

import UIKit

class EditProfileViewController: UIViewController {
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(EditProfileTableViewCell.self, forCellReuseIdentifier: EditProfileTableViewCell.identifier)
        return table
    }()
    
    private let user: User
    private let headerView: EditProfileHeader?
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        self.headerView = EditProfileHeader(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = headerView
        headerView?.delegate = self
        headerView?.frame = CGRect(x: 0, y: 0, width: view.width, height: 180)
        tableView.tableFooterView = UIView()
    }
    
    private func configureNavigationBar() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .twitterBlue
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
            
        } else {
            navigationController?.navigationBar.barTintColor = .twitterBlue
        }
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Actions
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapDone() {
        
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EditProfileTableViewCell.identifier,
            for: indexPath
        ) as? EditProfileTableViewCell else {
            preconditionFailure("EditProfile table cell error")
        }
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else {
            preconditionFailure("EditProfileOptions error")
        }
        
        cell.configure(viewModel: EditProfileViewModel(user: user, option: option))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else {
            return 0
        }
        return option == .bio ? 100 : 48
    }
}

// MARK: - EditProfileHeaderDelegate
extension EditProfileViewController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        
    }
}
