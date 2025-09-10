import UIKit

final class ArticleListViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)

    private var viewModel = ArticleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupNavBar()
        fetchArticles()
    }
    
    private func fetchArticles() {
        viewModel.getDataFromServer { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupNavBar() {
            title = "Articles"
            navigationController?.navigationBar.prefersLargeTitles = false
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = true
            searchController.searchBar.placeholder = "What's on your mind?"
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
}

extension ArticleListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCount()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ArticleCell",
            for: indexPath
        ) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        cell.title.text = viewModel.getAuthor(row: indexPath.row)
        cell.article.text = viewModel.getDescription(row: indexPath.row)
        cell.postedDate.text = viewModel.getFormattedDate(row: indexPath.row)
        cell.upload.image = UIImage(systemName: "square.and.arrow.up")
        viewModel.getImage(row: indexPath.row) { image in
            DispatchQueue.main.async {
                cell.postImage.image = image
            }
        }
        
        return cell
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.heightOfRow)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else {
            return
        }
           
        let selectedArticle = viewModel.getArticle(row: indexPath.row)
        // pass the article to the details viewcontroller
        detailsVC.article = selectedArticle
        detailsVC.closure = { [weak self] article in
                                print(article)
                            }
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
