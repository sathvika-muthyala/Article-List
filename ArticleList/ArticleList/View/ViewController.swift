import UIKit

final class ArticleListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel = ArticleViewModel()
    
    private var searchDebounceWorkItem: DispatchWorkItem?   // 🔹 for debounce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupNavBar()
        fetchArticles()
    }
    
    private func fetchArticles() {
        viewModel.getDataFromServer { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func setupNavBar() {
        title = "Articles"
        navigationController?.navigationBar.prefersLargeTitles = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "What's on your mind?"
        searchController.searchResultsUpdater = self
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
        
        cell.configure(with: viewModel, at: indexPath, in: tableView)
        return cell
    }

}

extension ArticleListViewController: UITableViewDelegate {
    
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

extension ArticleListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        
        // Cancel any existing work
        searchDebounceWorkItem?.cancel()
        
        // Create new work item with debounce of 1 sec
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.filterArticles(query: query)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
}
