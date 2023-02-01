//
//  EditProfileTableViewCell.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 30.01.2023.
//

import UIKit

protocol EditProfileTableViewCellDelegate: AnyObject {
    func updateUserInfo(_ cell: EditProfileTableViewCell, viewModel: EditProfileViewModel)
}

class EditProfileTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "EditProfileTableViewCell"
    weak var delegate: EditProfileTableViewCellDelegate?
    private var viewModel: EditProfileViewModel?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let infoTextField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 14)
        field.textAlignment = .left
        field.textColor = .twitterBlue
        return field
    }()
    
    let bioTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .twitterBlue
        textView.placeholderLabel.text = "Bio"
        return textView
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .white
        
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16, width: 100)
        
        contentView.addSubview(infoTextField)
        infoTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor,
                             bottom: bottomAnchor, right: rightAnchor,
                             paddingTop: 4, paddingLeft: 16, paddingRight: 8)
        infoTextField.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        
        contentView.addSubview(bioTextView)
        bioTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor,
                           bottom: bottomAnchor, right: rightAnchor,
                           paddingTop: 4, paddingLeft: 12, paddingRight: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    func configure(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.titleText
        infoTextField.text = viewModel.defaultValue
        bioTextView.text = viewModel.defaultValue
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
    }
    
    // MARK: - Actions
    @objc private func handleUpdateUserInfo() {
        guard let viewModel = viewModel else {
            return
        }
        delegate?.updateUserInfo(self, viewModel: viewModel)
    }
}
