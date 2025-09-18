//
//  ArticleTabBarController.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/17/25.
//

import UIKit

class ArticleTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let firstViewController = storyboard.instantiateViewController(withIdentifier: "ArticleListViewController") as? ArticleListViewController else {
            fatalError("Unable to Load")
        }
        let navigationController = UINavigationController(rootViewController: firstViewController)
        navigationController.tabBarItem = UITabBarItem(title: "Articles",
                                                       image: UIImage(systemName: "magnifyingglass"), tag: 0)
        let secondVC = DocViewController()
        secondVC.tabBarItem = UITabBarItem(title: "Recents",image: UIImage(systemName: "text.document"),tag: 1)
        
        let thirdVC = ArticleTabViewController()
        thirdVC.tabBarItem = UITabBarItem(title: "Favorites",image: UIImage(systemName: "star"),tag: 2)
        
        let fourthVC = ProfileViewController()
        fourthVC.tabBarItem = UITabBarItem(title: "Profile",image: UIImage(systemName: "person.circle"),tag: 3)
        
        viewControllers = [navigationController, secondVC, thirdVC, fourthVC]
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
        tabBar.barTintColor = .white
    }
}
