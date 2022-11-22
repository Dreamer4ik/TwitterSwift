//
//  AuthField.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.11.2022.
//

import UIKit

class AuthField: UITextField {
    
    enum FieldType {
        case fullname
        case username
        case email
        case password
        
        var title: String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .fullname:
                return "Fullname"
            case .username:
                return "Username"
            }
        }
    }
    
    private let type: FieldType
    
    init(type: FieldType) {
        self.type = type
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        autocapitalizationType = .none
        font = UIFont.systemFont(ofSize: 16)
        textColor = .white
        borderStyle = .none
        keyboardAppearance = .dark
        
        attributedPlaceholder = NSAttributedString(
            string: type.title,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        returnKeyType = .done
        autocorrectionType = .no
        
        if type == .password {
            textContentType = .oneTimeCode
            isSecureTextEntry = true
        } else if type == .email {
            keyboardType = .emailAddress
            textContentType = .emailAddress
        }
    }
}
