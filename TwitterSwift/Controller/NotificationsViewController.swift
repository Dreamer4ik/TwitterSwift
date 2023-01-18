//
//  NotificationsViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 20.11.2022.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        return table
    }()
    let refreshControl = UIRefreshControl()
    
    private var notifications = [Notification]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    private func fetchNotifications() {
        refreshControl.beginRefreshing()
        NotificationService.shared.fetchNotifications { notifications in
            self.notifications = notifications
            self.tableView.reloadData()
            self.checkIfUserIsFollowed(notifications: notifications)
            self.refreshControl.endRefreshing()
        }
    }
    
    private func checkIfUserIsFollowed(notifications: [Notification]) {
        for (index, notification) in notifications.enumerated() {
            if case .follow = notification.type {
                let user = notification.user
                UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
                    self.notifications[index].user.isFollowed = isFollowed
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    // MARK: - Actions
    @objc private func handleRefresh() {
        fetchNotifications()
    }
    
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationTableViewCell.identifier,
            for: indexPath
        ) as? NotificationTableViewCell else {
            preconditionFailure("UserTableViewCell")
        }
        let notification = notifications[indexPath.row]
        let viewModel = NotificationViewModel(notification: notification)
        cell.delegate = self
        cell.configure(viewModel: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let tweetID = notification.tweetID else {
            return
        }
        
        TweetService.shared.fetchTweet(withTweetID: tweetID) { tweet in
            print("tweet: \(tweet)")
            let vc = TweetViewController(tweet: tweet)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - NotificationTableViewCellDelegate
extension NotificationsViewController: NotificationTableViewCellDelegate {
    func didTapFollow(_ cell: NotificationTableViewCell) {
        guard let user = cell.notification?.user else {
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                cell.notification?.user.isFollowed = false
                print("unfollowUser: \(user.username)")
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { err, ref in
                cell.notification?.user.isFollowed = true
                print("followUser: \(user.username)")
            }
        }
    }
    
    func handleProfileImageTapped(_ cell: NotificationTableViewCell, viewModel: NotificationViewModel) {
        let vc = ProfileViewController(user: viewModel.user)
        navigationController?.pushViewController(vc, animated: true)
    }
}
