//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import Foundation
import UIKit


class NewsViewModel {
       
    var onFetchData: ((NewsData?) -> Void)?   //  Call back to update the view
    private let imageCache = NSCache<NSString, UIImage>()
    private let network: NetworkServiceProtocol

    init(networkService : NetworkServiceProtocol = NetworkService.instace ) {
        self.network = networkService
        imageCache.countLimit = 20                     // Maximum number of items in the cache
        imageCache.totalCostLimit = 20 * 1024 * 1024   // Maximum memory cost in bytes
        
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
    
    // It'll clear the cache
    @objc private func clearCache() {
        imageCache.removeAllObjects()
        print("Cache cleared")
    }

    // Func to fetch the news data by calling the method from Network Service
    func fetchNewsData() {
        network.downloadData(urlString: Constants.API_URL) { returnedNewsData in
            switch returnedNewsData {
            case .success(let data):
                self.decodeNewsData(data: data)
            case .failure(let failure):
                print("Error fetching data: \(failure)")
                self.onFetchData?(nil)
            }
        }
    }
    
    
    // Decode the news data to display in the view.
    private func decodeNewsData(data: Data) {
        self.network.Decode(data: data, type: NewsData.self) { decodedData in
            switch decodedData {
            case .success(let success):
                self.onFetchData?(success)

            case .failure(let failure):
                print("Error decoding data: \(failure)")
                self.onFetchData?(nil)

            }
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
    
}
