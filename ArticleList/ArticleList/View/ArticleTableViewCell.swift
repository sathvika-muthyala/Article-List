//
//  ArticleTableViewCell.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    private var viewModel = ArticleViewModel()
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var article: UILabel!
    @IBOutlet weak var upload: UIImageView!
    @IBOutlet weak var postedDate: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
}
