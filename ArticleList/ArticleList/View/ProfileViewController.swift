//
//  ProfileViewController.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/17/25.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel()
        label.textColor = .systemCyan
        label.text = "Profile Tab"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
    }

}
