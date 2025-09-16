//
//  ArticlesVC.swift
//  Reader
//
//  Created by Debashish on 15/09/25.
//

import UIKit
import CoreData

class ArticlesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet public var articleTable: UITableView?
    private let viewModel = ArticlesListViewModel()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupSearchBar()
        loadNews()
        setBottomTabBar()
        setTable()
    }
    func loadNews() {
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching latest news...")
        refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
        articleTable?.refreshControl = refreshControl
        viewModel.onUpdate = { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.articleTable?.reloadData()
        }
        viewModel.loadArticles()
    }
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
            
        searchController.searchBar.placeholder = "Search Articles"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    @objc private func refreshArticles() {
        if !NetworkMonitor.shared.isConnected {
            // Stop refreshing animation
            refreshControl.endRefreshing()
            let alert = UIAlertController(title: "No Internet",
                                          message: "You are offline. Showing cached articles.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        viewModel.loadArticles()
    }
    func setTable() {
        articleTable?.delegate = self
        articleTable?.dataSource = self
        articleTable?.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        articleTable?.reloadData()
    }
    
    func setBottomTabBar() {
        guard let viewController = UIApplication.topViewController() else {
            print("No top view controller found to set up the tab bar.")
            return
        }
        let tabBar = BMTabBarMenu()
        tabBar.addTabView(in: viewController.view)
        tabBar.setUpTabView(selectedIndex: 0)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell ?? ArticleCell()
        let article = viewModel.filteredArticles[indexPath.row]
        cell.selectionStyle = .none
        cell.titleLabel.text = article.title
        cell.authorLabel.text = article.author ?? "Unknown"
        cell.newsIcon.loadImage(from: article.urlToImage ?? "", placeholder: UIImage(systemName: "photo"))
        cell.bookmarkIcon.image = article.isBookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        cell.bookmarkIcon.isUserInteractionEnabled = true
        cell.bookmarkIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTap(_:))))
        return cell
    }
    @objc private func handleBookmarkTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view,
              let cell = tappedView.superview?.superview as? ArticleCell,
              let indexPath = articleTable?.indexPath(for: cell) else { return }
        
        viewModel.toggleBookmark(at: indexPath.row)
        articleTable?.reloadRows(at: [indexPath], with: .automatic)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension ArticlesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.filterArticles(with: query)
    }
}
