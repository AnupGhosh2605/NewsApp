//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import Foundation
import UIKit
import Combine

class NewsViewModel : ObservableObject {
       
    private let imageCache = NSCache<NSString, UIImage>()
    private let network: NetworkServiceProtocol
    private var cancellables  = Set<AnyCancellable>()

    // For Core Data
    var coreDataManager : CoreNewsDataManager
    private var articles: [ArticleEntity] = []

    @Published var newsData : NewsData?
    
    init(networkService: NetworkServiceProtocol = NetworkService.instace, coreDataManager : CoreNewsDataManager = CoreNewsDataManager.instance) {
           self.network = networkService
           self.coreDataManager = coreDataManager
           callObserverForClearImageCache()
           addSubscriber()
       }

    // Add Subscriber for reading CoreData
    private func addSubscriber(){
        coreDataManager.$newsPublisher
            .sink(receiveValue: { [weak self] articles in
                self?.articles = articles ?? []
                self?.createNewsData()
            })
            .store(in: &cancellables)
    }
    
    
    func fetchNews(){
        self.fetchNewsData()    //  call the rest API
    }
    
    
    
    // Func to fetch the news data by calling the method from Network Service
    func fetchNewsData() {
        network.downloadData(urlString: Constants.API_URL) { returnedNewsData in
            switch returnedNewsData {
            case .success(let data):
                self.decodeNewsData(data: data)
            case .failure(_):
                self.coreDataManager.FetchNewsFromCoreData()

//                DispatchQueue.main.async {
//                    self.coreDataManager.FetchNewsFromCoreData()   // call data from core data
//                }
            }
        }
    }
    
    
    // Decode the news data to display in the view.
     func decodeNewsData(data: Data) {
        self.network.Decode(data: data, type: NewsData.self) { decodedData in
            switch decodedData {
            case .success(let success):
                DispatchQueue.main.async {
                    self.newsData = success
                }
                DispatchQueue.global(qos: .background).async {
                    self.addNewsDataToCoreData(data : success)
                }
            case .failure(let failure):
                print("Error decoding data: \(failure)")
            }
        }
    }
    
    private func addNewsDataToCoreData(data : NewsData) {
        for item in data.articles ?? [] {
            coreDataManager.addEntity(article: item)
        }
    }
    
    // Fetch the image data from URL anc convert it to UIImage
    func fetchImageData(imageUrl : String,completion: @escaping (UIImage?) -> Void) {
        
        // Check is image is present in the cache
        if let cachedImage = imageCache.object(forKey: imageUrl as NSString) {
            completion(cachedImage)
            return
        }
        
        network.downloadData(urlString: imageUrl) { returnedImageData in
            switch returnedImageData {
            case .success(let data):
                if let image = UIImage(data: data) {
                    // Storing image with the key
                    self.imageCache.setObject(image, forKey: imageUrl as NSString)
                    completion(image)
                }
                else {
                    completion(nil)
                }
            case .failure(let failure):
                print("Error fetching imageData: \(failure)")
                completion(nil)
            }
        }
    }
    
    func createNewsData(){
        // for no data
        guard !articles.isEmpty else {
               self.newsData = NewsData(status: "failed", totalResults: 0, articles: [])
               return
           }
        
        
        let mappedArticles = articles.compactMap { entity -> Article? in
            guard let author = entity.author,
                  let title = entity.title,
                  let desc = entity.desc,
                  let url = entity.url,
                  let urlToImage = entity.urlToImage else {
                return nil
            }
            
            return Article(author: author, title: title, description: desc, url: url, urlToImage: urlToImage)
        }
        let news = NewsData(status: "ok", totalResults: mappedArticles.count, articles: mappedArticles)
        
        self.newsData = news
    }
    
    
    
    private func callObserverForClearImageCache(){
        imageCache.countLimit = 25                     // Maximum number of items in the cache
        imageCache.totalCostLimit = 25 * 1024 * 1024   // Maximum memory cost in bytes
        
        // Add Observers to check if app is using too much memory
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // Cehcks if the app goes to background from the foreground.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    //  clear the cache
    @objc private func clearCache() {
        imageCache.removeAllObjects()
        print("Cache cleared")
    }

    
}
