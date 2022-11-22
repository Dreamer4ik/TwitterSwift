//
//  RegisterViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.11.2022.
//

import UIKit

class RegisterViewController: UIViewController {
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    
    private let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    private let alreadyHaveAccountButton = Utilities.attributedButton("Already have an account?   ",
                                                                      "Log In")
    private let emailTextField = AuthField(type: .email)
    private let passwordTextField = AuthField(type: .password)
    private let fullnameTextField = AuthField(type: .fullname)
    private let usernameTextField = AuthField(type: .username)
    
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .twitterBlue
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        selectPhotoButton.setDimensions(width: 150, height: 150)
        
        configureContainerView()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDismiss))
        view.addGestureRecognizer(tap)
        
        alreadyHaveAccountButton.addTarget(self, action: #selector(didTapAlreadyHaveAccountButton), for: .touchUpInside)
        selectPhotoButton.addTarget(self, action: #selector(didTapSelectPhoto), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    private func configureContainerView() {
        guard let imageEmail = UIImage(named: "ic_mail_outline_white_2x-1") else { return }
        let emailContainerView = UIView().inputContainerView(image: imageEmail, textField: emailTextField)
        
        
        guard let imagePassword = UIImage(named: "ic_lock_outline_white_2x") else { return }
        let passwordContainerView = UIView().inputContainerView(image: imagePassword, textField: passwordTextField)
        
        guard let imageFullname = UIImage(named: "ic_person_outline_white_2x") else { return }
        let fullnameContainerView = UIView().inputContainerView(image: imageFullname, textField: fullnameTextField)
        
        guard let imageUsername = UIImage(named: "ic_person_outline_white_2x") else { return }
        let usernameContainerView = UIView().inputContainerView(image: imageUsername, textField: usernameTextField)
        
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   fullnameContainerView,
                                                   usernameContainerView,
                                                   signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        view.addSubview(stack)
        stack.anchor(top: selectPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32,
                     paddingLeft: 32, paddingRight: 32)
        
    }
    
    // MARK: - Actions
    
    @objc private func didTapSignUp() {
        
    }
    
    @objc private func didTapSelectPhoto() {
        present(imagePicker, animated: true)
    }
    
    @objc private func didTapDismiss() {
        view.endEditing(true)
    }
    
    @objc private func didTapAlreadyHaveAccountButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        selectPhotoButton.layer.borderColor = UIColor.white.cgColor
        selectPhotoButton.layer.borderWidth = 3
        selectPhotoButton.layer.cornerRadius = 150/2
        selectPhotoButton.layer.masksToBounds = true
        selectPhotoButton.imageView?.contentMode = .scaleAspectFill
        selectPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
}
