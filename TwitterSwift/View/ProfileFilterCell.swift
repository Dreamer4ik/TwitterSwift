//
//  ProfileFilterCell.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.12.2022.
//

import UIKit

class ProfileFilterCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "ProfileFilterCell"
    
    var option: ProfileFilterOptions?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) :
            UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? .twitterBlue : .lightGray
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureFilter(option: ProfileFilterOptions) {
        titleLabel.text = option.description
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
}
