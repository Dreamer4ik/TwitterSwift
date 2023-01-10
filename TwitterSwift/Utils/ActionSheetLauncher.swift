//
//  ActionSheetLauncher.swift
//  TwitterSwift
//
//  Created by Ivan Potapenko on 09.01.2023.
//

import UIKit

protocol ActionSheetLauncherDelegate: AnyObject {
    func didSelect(option: ActionSheetOptions)
}

class ActionSheetLauncher: NSObject {
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.register(ActionSheetCell.self, forCellReuseIdentifier: ActionSheetCell.identifier)
        return table
    }()
    
    private let blackView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGroupedBackground
        return button
    }()
    
    private let footerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let user: User
    private var viewModel: ActionSheetViewModel
    private var window: UIWindow?
    private let height: CGFloat
    weak var delegate: ActionSheetLauncherDelegate?
    
    init(user: User) {
        self.user = user
        self.viewModel = ActionSheetViewModel(user: user)
        self.height = CGFloat(viewModel.options.count * 60 + 100)
        super.init()
        configureTable()
    }
    
    // MARK: - Helpers
    
    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
    }
    
    private func showTableView(_ shouldShow: Bool) {
        guard let window = window else {
            return
        }
        let y = shouldShow ? window.height - height : window.height
        tableView.frame.origin.y = y
    }
    
    func show() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else { return }
        
        self.window = window
        
        window.addSubview(blackView)
        blackView.frame = window.frame
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        blackView.addGestureRecognizer(tap)
        
        window.addSubview(tableView)
        
        tableView.frame = CGRect(
            x: 0,
            y: window.height,
            width: window.width,
            height: height
        )
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.showTableView(true)
        }
    }
    
    // MARK: - Selectors
    @objc private func handleDismissal() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.showTableView(false)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ActionSheetLauncher: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ActionSheetCell.identifier,
            for: indexPath
        ) as? ActionSheetCell else {
            preconditionFailure("ActionSheetCell error")
        }
        let option = viewModel.options[indexPath.row]
        cell.configure(option: option)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView.addSubview(cancelButton)
        cancelButton.centerY(inView: footerView)
        let cancelSize: CGFloat = 50
        cancelButton.anchor(left: footerView.leftAnchor, right: footerView.rightAnchor,
                            paddingLeft: 12, paddingRight: 12, height: cancelSize)
        cancelButton.layer.cornerRadius = cancelSize/2
        cancelButton.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.showTableView(false)
        } completion: { _ in
            self.delegate?.didSelect(option: option)
        }
    }
}
