//
//  ArticleListCoordinator.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/15/25.
//

import UIKit

protocol ArticleListCoordinatorProtocol {
    func navigateToDetail(_ detailsVC: DetailsViewController)
}

final class ArticleListCoordinator: ArticleListCoordinatorProtocol {
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    func navigateToDetail(_ detailsVC: DetailsViewController) {
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

