//
//  LoginViewController.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.11.2022.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: - Properties
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TwitterLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let emailTextField = AuthField(type: .email)
    private let passwordTextField = AuthField(type: .password)
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let haveNotAccountButton = Utilities.attributedButton("Don't have an account?   ",
                                                                  "Sign Up")
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .twitterBlue
        configureNavBar()
        
        view.addSubview(iconImageView)
        iconImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        iconImageView.setDimensions(width: 150, height: 150)
        
        configureContainerView()
        
        view.addSubview(haveNotAccountButton)
        haveNotAccountButton.centerX(inView: view)
        haveNotAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                    right: view.rightAnchor, height: 32)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDismiss))
        view.addGestureRecognizer(tap)
        
        haveNotAccountButton.addTarget(self, action: #selector(didTapHaveNotAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }
    
    private func configureContainerView() {
        guard let imageEmail = UIImage(named: "ic_mail_outline_white_2x-1") else { return }
        let emailContainerView = UIView().inputContainerView(image: imageEmail, textField: emailTextField)
        
        
        guard let imagePassword = UIImage(named: "ic_lock_outline_white_2x") else { return }
        let passwordContainerView = UIView().inputContainerView(image: imagePassword, textField: passwordTextField)
        
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        view.addSubview(stack)
        stack.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingLeft: 32, paddingRight: 32)
        
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    // MARK: - Actions
    @objc private func didTapLogin() {
        guard let email = emailTextField.text?.lowercased(),
              let password = passwordTextField.text else {
            return
        }
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error user log in \(error.localizedDescription)")
                return
            }
            
            var window: UIWindow?
            
            if #unavailable(iOS 15) {
                window = UIApplication.shared.windows.first(where: {
                    $0.isKeyWindow
                })
            } else {
                window = UIApplication.shared.connectedScenes
                // Keep only active scenes, onscreen and visible to the user
                    .filter { $0.activationState == .foregroundActive }
                // Keep only the first `UIWindowScene`
                    .first(where: { $0 is UIWindowScene })
                // Get its associated windows
                    .flatMap({ $0 as? UIWindowScene })?.windows
                // Finally, keep only the key window
                    .first(where: \.isKeyWindow)
            }
            
            guard let windowFinall = window else {
                return
            }
            
            guard let tab = windowFinall.rootViewController as? MainTabBarViewController else {
                return
            }
            tab.authenticateUserAndConfigureUI()
            
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapHaveNotAccountButton() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapDismiss() {
        view.endEditing(true)
    }
}
