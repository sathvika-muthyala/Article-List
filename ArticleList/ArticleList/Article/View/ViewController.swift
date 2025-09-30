import UIKit

final class ArticleListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel = ArticleViewModel()
    private var coordinatorFlowDelegate: ArticleListCoordinatorProtocol?
    private var searchDebounceWorkItem: DispatchWorkItem?
    private let refreshControlView = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var lastQuery: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupNavBar()
        setupLoader()
        initializeCoordinator()
        setupRefreshControl()
        
        Task { await fetchArticles() }
    }
    
    @MainActor
    private func fetchArticles() async {
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        tableView.isHidden = true

        let startTime = Date()
        
        let errorState = await viewModel.getDataFromServer(type: ArticleList.self)
        
        let elapsed = Date().timeIntervalSince(startTime)
        let delay = max(0, 1.0 - elapsed)
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        activityIndicator.stopAnimating()
        tableView.isHidden = false

        if let _ = errorState {
            showAlert(title: "Article List",
                      message: viewModel.errorMessage ?? "Something went wrong")
        } else {
            tableView.reloadData()
        }
    }
    // MARK: - Navbar SetUp
    private func setupNavBar() {
        title = "Articles"
        navigationController?.navigationBar.prefersLargeTitles = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "What's on your mind?"
        searchController.searchResultsUpdater = self
        searchController.searchBar.setValue("Done", forKey: "cancelButtonText")
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
 
    // MARK: - Coordinator Initializer
    private func initializeCoordinator() {
        if coordinatorFlowDelegate == nil {
            coordinatorFlowDelegate = ArticleListCoordinator(navigationController: navigationController)
        }
    }
    
    // MARK: - Refresh Controller SetUp
    private func setupRefreshControl() {
        refreshControlView.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControlView
    }
    
    // MARK: - Refreshing Data
    @objc private func refreshData() {
        lastQuery = ""
        viewModel.filterArticles(query: "")
        
        Task {
            let errorState = await viewModel.getDataFromServer(type: ArticleList.self)
            
            refreshControlView.endRefreshing()
            
            if let _ = errorState {
                showAlert(
                    title: "Article List",
                    message: viewModel.errorMessage ?? "Something went wrong"
                )
            } else {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Loader
    private func setupLoader() {
        activityIndicator.color = .systemCyan
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
}

// MARK: - Table View Datasource
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

// MARK: - Table View Delegate
extension ArticleListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController")
                as? DetailsViewController else { return }
        
        let row = indexPath.row
        guard let article = viewModel.getArticle(row: row) else { return }
        detailsVC.viewModel = DetailsViewModel(article: article)
        detailsVC.delegate = self 
        detailsVC.rowIndex = row
//        detailsVC.closure = { [weak self] updated in
//            guard let self = self, let updated = updated else { return }
//            guard row < self.viewModel.articleList.count else { return }
//            self.viewModel.articleList[row] = updated
//            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//        }
        
        coordinatorFlowDelegate?.navigateToDetail(detailsVC)

    }
}

// MARK: - Search Result
extension ArticleListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        let effectiveQuery = query.isEmpty ? lastQuery : query
        lastQuery = effectiveQuery
        
        searchDebounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.filterArticles(query: effectiveQuery)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }

}

extension ArticleListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterArticles(query: lastQuery)
        tableView.reloadData()
        searchController.searchBar.resignFirstResponder()
    }
}

extension ArticleListViewController: ArticleDetailsDelegate {
    func didUpdateArticle(_ article: Article, at index: Int) {
        guard index < viewModel.articleList.count else { return }
        viewModel.articleList[index] = article
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

