//
//  DocViewController.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/17/25.
//

import UIKit

class RecentsViewController: UIViewController {
    

    private let recentsTableView = UITableView()
    private var viewModel = CountryViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchDebounceWorkItem: DispatchWorkItem?
    private let refreshControlView = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recentsTableView.dataSource = self
        setUpTableView()
        fetchCountries()
        setupNavBar()
        setupRefreshControl()
        setupLoader()
    }
    private func setUpTableView() {
        recentsTableView.translatesAutoresizingMaskIntoConstraints = false
        recentsTableView.register(CountryTableViewCell.self, forCellReuseIdentifier: "CountryCell")
        recentsTableView.rowHeight = UITableView.automaticDimension
        recentsTableView.estimatedRowHeight = 70
        view.addSubview(recentsTableView)
        
        NSLayoutConstraint.activate([
            recentsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            recentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recentsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func fetchCountries() {
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
        recentsTableView.isHidden = true

        let startTime = Date()

        viewModel.getDataFromServer(type: Country.self) { [weak self] errorState in
            guard let self = self else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            let delay = max(0, 1.0 - elapsed)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.activityIndicator.stopAnimating()
                self.recentsTableView.isHidden = false

                if let _ = errorState {
                    self.showAlert(title: "Country List",
                                   message: self.viewModel.errorMessage ?? "")
                } else {
                    self.recentsTableView.reloadData()
                }
            }
        }

    }
    
    private func setupNavBar() {
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "What's on your mind?"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupRefreshControl() {
            refreshControlView.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            recentsTableView.refreshControl = refreshControlView
        }
        
    @objc private func refreshData() {
        viewModel.getDataFromServer(type: Country.self) { [weak self] errorState in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.refreshControlView.endRefreshing()
                
                if let _ = errorState {
                    self.showAlert(
                        title: "Country List",
                        message: self.viewModel.errorMessage ?? "Something went wrong"
                    )
                } else {
                    self.recentsTableView.reloadData()
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

extension RecentsViewController: UITableViewDataSource {
    func tableView(_ recentsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCount()
    }

    func tableView(_ recentsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = recentsTableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as? CountryTableViewCell else {
            fatalError("Unable to dequeue CountryCell as CountryTableCell")
        }
        cell.configure(with: viewModel, at: indexPath, in: recentsTableView)
        return cell
    }
   
}

extension RecentsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchDebounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.filterCountries(query: query)
            DispatchQueue.main.async {
                self?.recentsTableView.reloadData()
            }
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
}
