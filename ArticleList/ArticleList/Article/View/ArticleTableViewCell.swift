//
//  ArticleTableViewCell.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/8/25.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var article: UILabel!
    @IBOutlet weak var upload: UIImageView!
    @IBOutlet weak var postedDate: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    private var currentIndexPath: IndexPath?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImage.image = nil
    }
    
    func configure(with viewModel: ArticleViewModel, at indexPath: IndexPath, in tableView: UITableView) {
        title.text = viewModel.getAuthor(row: indexPath.row)
        article.text = viewModel.getDescription(row: indexPath.row)
        postedDate.text = viewModel.getFormattedDate(row: indexPath.row)
        upload.image = UIImage(systemName: "square.and.arrow.up")
        
        currentIndexPath = indexPath
        
        Task { [weak tableView] in
            if let image = await viewModel.getImage(row: indexPath.row),
               let visibleCell = tableView?.cellForRow(at: indexPath) as? ArticleTableViewCell {
                visibleCell.postImage.image = image
            }
        }

    }

}
