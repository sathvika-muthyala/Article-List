import UIKit

final class ViewController: UIViewController {
    
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
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.placeholder = "What's on your mind?"
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
}

extension ViewController: UITableViewDataSource {
    
    func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            return displayFormatter.string(from: date)
        }
        return isoString
    }
    
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
        
        if let article = viewModel.getArticle(row: indexPath.row) {
            cell.title.text = article.author ?? "Unknown"
            cell.article.text = article.description
            cell.postedDate.text = formatDate(article.dateOfPublication)
            cell.upload.image = UIImage(systemName: "square.and.arrow.up")
            
            if let s = article.imageUrl, let url = URL(string: s) {
                URLSession.shared.dataTask(with: url) { [weak cell] data, _, _ in
                    guard let data = data, let img = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        cell?.postImage.image = img
                    }
                }.resume()
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.heightOfRow)
    }
}
