//
//  Utilities.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 22.11.2022.
//

import UIKit

class Utilities {
    static func configureNavBar(vc: UIViewController) {
        if #available(iOS 15.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .white
            vc.navigationItem.standardAppearance = barAppearance
            vc.navigationItem.scrollEdgeAppearance = barAppearance
            
        } else {
            vc.navigationController?.navigationBar.backgroundColor = .white
        }
    }
    
   static func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(
            string: firstPart,
            attributes: [.font: UIFont.systemFont(ofSize: 16),
                         .foregroundColor: UIColor.white])
        
        attributedTitle.append(NSAttributedString(
            string: secondPart,
            attributes: [.font: UIFont.boldSystemFont(ofSize: 17),
                         .foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
    
    static func createButtonForTweetHeader(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    static func createButtonForTweetCell(withImageName imageName: String) -> UIButton{
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        return button
    }
}
