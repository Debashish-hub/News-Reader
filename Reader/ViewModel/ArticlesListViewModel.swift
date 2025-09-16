//
//  ArticlesListViewModel.swift
//  Reader
//
//  Created by Debashish on 16/09/25.
//
import UIKit

final class ArticlesListViewModel {
    private let repository = NewsRepository()
    var articles: [ArticleEntity] = []
    var filteredArticles: [ArticleEntity] = []
    var onUpdate: (() -> Void)?
    
    func loadArticles() {
        repository.fetchArticles { [weak self] cached in
            DispatchQueue.main.async {
                self?.articles = cached
                self?.filteredArticles = cached
                self?.onUpdate?()
            }
        }
    }
    func filterArticles(with query: String) {
        guard !query.isEmpty else {
            filteredArticles = articles
            onUpdate?()
            return
        }
            
        filteredArticles = articles.filter { article in
            let titleMatch = article.title?.lowercased().contains(query.lowercased()) ?? false
            let authorMatch = article.author?.lowercased().contains(query.lowercased()) ?? false
            return titleMatch || authorMatch
        }
            
        onUpdate?()
    }
    func toggleBookmark(at index: Int) {
        let article = articles[index]
        repository.toggleBookmark(for: article)
        onUpdate?()
    }
    
    func loadBookmarks() {
        articles = repository.loadBookmarkedArticles()
        onUpdate?()
    }
}
