//
//  NewsAPIService.swift
//  Reader
//
//  Created by Debashish on 16/09/25.
//


import Foundation
import CoreData

final class NewsAPIService {
    private let apiKey = "67843e97a6414a079a84c2a0ec86571e"
    private let session = URLSession.shared
    
    func fetchTopHeadlines(completion: @escaping (Result<[Article], Error>) -> Void) {
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let newsResponse = try decoder.decode(NewsResponse.self, from: data)
                completion(.success(newsResponse.articles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


final class NewsRepository {
    private let api = NewsAPIService()
    private let context = CoreDataManager.shared.context
    
    func fetchArticles(completion: @escaping ([ArticleEntity]) -> Void) {
        if NetworkMonitor.shared.isConnected {
            api.fetchTopHeadlines { result in
                switch result {
                case .success(let articles):
                    print("Fetched articles from API. Caching locally.")
                    self.saveArticles(articles)
                    completion(self.loadCachedArticles())
                case .failure:
                    print("Failed to fetch articles from API. Loading cached articles.")
                    completion(self.loadCachedArticles())
                }
            }
        } else {
            print("No internet connection. Loading cached articles.")
            completion(self.loadCachedArticles())
        }
    }
    
    private func saveArticles(_ articles: [Article]) {
        let context = CoreDataManager.shared.context

        for article in articles {
            // Check if article already exists
            let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "url == %@", article.url ?? "")

            if let existing = try? context.fetch(fetchRequest).first {
                // Update existing fields but keep bookmark
                existing.title = article.title
                existing.author = article.author
                existing.urlToImage = article.urlToImage
            } else {
                // Create new entity
                let entity = ArticleEntity(context: context)
                entity.title = article.title
                entity.author = article.author
                entity.urlToImage = article.urlToImage
                entity.url = article.url
                entity.isBookmarked = article.isBookmarked ?? false
            }
        }

        CoreDataManager.shared.saveContext()
    }
    
    private func loadCachedArticles() -> [ArticleEntity] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        do {
            let entities = try context.fetch(fetchRequest)
            return entities
        } catch {
            print("Failed to fetch cached articles: \(error)")
            return []
        }
    }
    
    func toggleBookmark(for article: ArticleEntity) {
        article.isBookmarked.toggle()
        try? context.save()
    }
    
    func loadBookmarkedArticles() -> [ArticleEntity] {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmarked == YES")
        return (try? context.fetch(request)) ?? []
    }
}
