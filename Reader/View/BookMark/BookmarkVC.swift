//
//  BookmarkVC.swift
//  Reader
//
//  Created by Debashish on 16/09/25.
//

import UIKit

class BookmarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet public var bookmarkTable: UITableView?
    private let viewModel = ArticlesListViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadBookmarks()
        setTable()
        setBottomTabBar()
        viewModel.onUpdate = { [weak self] in
            self?.bookmarkTable?.reloadData()
        }
        // Do any additional setup after loading the view.
    }

    func setTable() {
        bookmarkTable?.delegate = self
        bookmarkTable?.dataSource = self
        bookmarkTable?.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        bookmarkTable?.reloadData()
    }
    
    func setBottomTabBar() {
        guard let viewController = UIApplication.topViewController() else {
            print("No top view controller found to set up the tab bar.")
            return
        }
        let tabBar = BMTabBarMenu()
        tabBar.addTabView(in: viewController.view)
        tabBar.setUpTabView(selectedIndex: 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell ?? ArticleCell()
        let article = viewModel.articles[indexPath.row]
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
              let indexPath = bookmarkTable?.indexPath(for: cell) else { return }
        
        viewModel.toggleBookmark(at: indexPath.row)
        viewModel.loadBookmarks()
        bookmarkTable?.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
