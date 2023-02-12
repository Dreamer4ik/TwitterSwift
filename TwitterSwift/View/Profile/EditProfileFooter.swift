//
//  EditProfileFooter.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 11.02.2023.
//

import UIKit

protocol EditProfileFooterDelegate: AnyObject {
    func didTapLogOut()
}

class EditProfileFooter: UIView {
    // MARK: - Properties
    weak var delegate: EditProfileFooterDelegate?
    
    private let logOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGroupedBackground
        return button
    }()
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        addSubview(logOutButton)
        logOutButton.center(inView: self)
        logOutButton.addTarget(self, action: #selector(didTapLogOut), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logOutButton.setDimensions(width: width - 32, height: 50)
    }
    
    // MARK: - Actions
    @objc private func didTapLogOut() {
        delegate?.didTapLogOut()
    }
}
