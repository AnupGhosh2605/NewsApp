//
//  Constants.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import Foundation

// This file will contain call the raw text


struct Constants {
   static let API_KEY = "b09e3d651a95441aa842b38921f5a818"
   static let API_URL = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=\(API_KEY)"
   static let NavBarTitle = "Daily Headlines"
}


struct ReuseIdentifier {
    static let newsListTableViewCell = "NewsListTableViewCell"
    static let newsListTopTableViewCell = "NewsListTopTableViewCell"

}
