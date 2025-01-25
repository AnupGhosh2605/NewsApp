//
//  NewsModel.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import Foundation


import Foundation

struct NewsData: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

struct Article: Codable {
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
}


