//
//  ArticleModel.swift
//  Senpiper
//
//  Created by Nishant Minerva on 16/06/23.
//

import Foundation

class Article {
    var title: String
    var author: String
    var description: String
    var imageURL: URL?
    
    init(title: String, author: String, description: String, imageURL: URL?) {
        self.title = title
        self.author = author
        self.description = description
        self.imageURL = imageURL
    }
}
