//
//  DetailsViewController.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/10/25.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var updateText: UITextField!
    
    var article: Article?
    var closure: ((Article?) -> Void?)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText.text = article?.title ?? ""
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backToPreviousScreen))
    }
    
    @objc func backToPreviousScreen() {
        article?.title = updateText.text ?? ""
        
        guard let closure = closure else { return }
        closure(article)
        self.navigationController?.popViewController(animated: true)
    }
}

