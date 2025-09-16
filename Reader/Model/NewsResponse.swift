//
//  NewsResponse.swift
//  Reader
//
//  Created by Debashish on 16/09/25.
//


struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String?
    let author: String?
    let urlToImage: String?
    let url: String?
    var isBookmarked: Bool? = false
}


struct Source: Codable {
    let id: String?
    let name: String
}

extension Article {
    init(entity: ArticleEntity) {
        self.title = entity.title ?? ""
        self.author = entity.author
        self.urlToImage = entity.urlToImage
        self.url = entity.url ?? ""
        self.isBookmarked = entity.isBookmarked
    }
}
