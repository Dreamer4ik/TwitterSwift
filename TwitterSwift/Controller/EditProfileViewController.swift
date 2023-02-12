//
//  EditProfileViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 30.01.2023.
//

import UIKit

protocol EditProfileViewControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileViewController, wantsToUpdate user: User)
    func handleLogOut()
}

class EditProfileViewController: UIViewController {
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(EditProfileTableViewCell.self, forCellReuseIdentifier: EditProfileTableViewCell.identifier)
        return table
    }()
    
    weak var delegate: EditProfileViewControllerDelegate?
    private var user: User
    private let headerView: EditProfileHeader?
    private let footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    private var selectedImage: UIImage?
    
    private var userInfoChanged = false
    
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
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
    
    // MARK: - API
    private func updateUserData() {
        
        if imageChanged && !userInfoChanged {
            updateProfileImage()
        }
        
        if !imageChanged && userInfoChanged {
            UserService.shared.saveUserData(user: user) { error, ref in
                self.dismiss(animated: true) {
                    self.delegate?.controller(self, wantsToUpdate: self.user)
                }
            }
        }
        
        if imageChanged && userInfoChanged {
            UserService.shared.saveUserData(user: user) { error, ref in
                self.updateProfileImage()
            }
        }
    }
    
    private func updateProfileImage() {
        guard let image = selectedImage else {
            return
        }
        
        UserService.shared.updateProfileImage(image: image) { profileImageUrl in
            self.user.profileImageUrl = profileImageUrl
            self.dismiss(animated: true) {
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
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
        
        tableView.tableFooterView = footerView
        footerView.delegate = self
        footerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 50)
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
    }
    
    // MARK: - Actions
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapDone() {
        view.endEditing(true)
        guard imageChanged || userInfoChanged else {
            return
        }
        updateUserData()
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
        
        cell.delegate = self
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
        present(imagePicker, animated: true)
    }
}

// MARK: - EditProfileFooterDelegate
extension EditProfileViewController: EditProfileFooterDelegate {
    func didTapLogOut() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive,handler: { _ in
            self.dismiss(animated: true) {
                self.delegate?.handleLogOut()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        headerView?.setImage(image: image)
        selectedImage = image
        
        dismiss(animated: true)
    }
}

// MARK: - EditProfileTableViewCellDelegate
extension EditProfileViewController: EditProfileTableViewCellDelegate {
    func updateUserInfo(_ cell: EditProfileTableViewCell, viewModel: EditProfileViewModel) {
        
        userInfoChanged = true
        
        switch viewModel.option {
        case .fullname:
            guard let fullname = cell.infoTextField.text else {
                return
            }
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else {
                return
            }
            user.username = username
        case .bio:
            user.bio = cell.bioTextView.text
        }
    }
}
