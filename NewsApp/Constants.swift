//
//  Constants.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import Foundation

// This file will contain call the raw text


struct Constants {
   static let API_KEY = ""
   static let API_URL = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=\(API_KEY)"
   static let NavBarTitle = "Daily Headlines"
}


struct ReuseIdentifier {
    static let newsListTableViewCell = "NewsListTableViewCell"
    static let newsListTopTableViewCell = "NewsListTopTableViewCell"

}
