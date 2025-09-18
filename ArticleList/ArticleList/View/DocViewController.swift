//
//  DocViewController.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/17/25.
//

import UIKit

class DocViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel()
        label.textColor = .systemCyan
        label.text = "Recent Articles"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
