//
//  ExploreViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit

class ExploreViewController: UIViewController {

    // MARK: - Properties
    private let usersTable: UITableView = {
        let table = UITableView()
        table.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return table
    }()
    
    private var users = [User]() {
        didSet {
            usersTable.reloadData()
        }
    }
    
    private var filteredUsers = [User]() {
        didSet {
            usersTable.reloadData()
        }
    }
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    private func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Explore"
        
        view.addSubview(usersTable)
        usersTable.frame = view.bounds
        usersTable.delegate = self
        usersTable.dataSource = self
        usersTable.separatorStyle = .none
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    // MARK: - Actions

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UserTableViewCell.identifier,
            for: indexPath
        ) as? UserTableViewCell else {
            preconditionFailure("UserTableViewCell")
        }
        
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.configure(user: user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UISearchResultsUpdating
extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        filteredUsers = users.filter({
            $0.username.contains(searchText)
        })
        
        usersTable.reloadData()
    }
}
