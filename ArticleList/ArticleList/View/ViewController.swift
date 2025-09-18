import UIKit

final class ArticleListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel = ArticleViewModel()
    var coordinatorFlowDelegate: ArticleListCoordinatorProtocol?
    private var searchDebounceWorkItem: DispatchWorkItem?
    private let refreshControlView = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupNavBar()
        setupLoader()
        fetchArticles()
        initializeCoordinator()
        setupRefreshControl()
    }
    
    private func fetchArticles() {
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        tableView.isHidden = true

        let startTime = Date()

        viewModel.getDataFromServer { [weak self] errorState in
            guard let self = self else { return }

            DispatchQueue.main.async {
                let elapsed = Date().timeIntervalSince(startTime)
                let delay = max(0, 1.0 - elapsed)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    if let _ = errorState {
                        self.showAlert(title: "Article List",
                                       message: self.viewModel.errorMessage ?? "")
                    } else {
                        self.tableView.reloadData()
                    }
                }
            }
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
    
    private func initializeCoordinator() {
        if coordinatorFlowDelegate == nil {
                coordinatorFlowDelegate = ArticleListCoordinator(navigationController: navigationController)
            }
    }
    
    private func setupRefreshControl() {
            refreshControlView.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            tableView.refreshControl = refreshControlView
        }
        
    @objc private func refreshData() {
        viewModel.getDataFromServer { [weak self] errorState in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.refreshControlView.endRefreshing()
                
                if let _ = errorState {
                    self.showAlert(title: "Article List",
                                   message: self.viewModel.errorMessage ?? "Something went wrong")
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func setupLoader() {
        activityIndicator.color = .systemCyan
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
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
        
        coordinatorFlowDelegate?.navigateToDetail(detailsVC)

    }
}

extension ArticleListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchDebounceWorkItem?.cancel()
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
