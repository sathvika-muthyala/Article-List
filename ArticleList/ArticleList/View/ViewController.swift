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

        // Optional: avoid wrong images on reused cells
        viewModel.getImage(row: indexPath.row) { [weak tableView] image in
            DispatchQueue.main.async {
                if let visibleCell = tableView?.cellForRow(at: indexPath) as? ArticleTableViewCell {
                    visibleCell.postImage.image = image
                }
            }
        }
        
        return cell
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.heightOfRow)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController")
                as? DetailsViewController else { return }

        let row = indexPath.row
        guard let article = viewModel.getArticle(row: row) else { return }
        detailsVC.viewModel = DetailsViewModel(article: article)
        detailsVC.closure = { [weak self] updated in
            guard let self = self, let updated = updated else { return }
            guard row < self.viewModel.articleList.count else { return }
            self.viewModel.articleList[row] = updated
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }

        navigationController?.pushViewController(detailsVC, animated: true)
    }


}
