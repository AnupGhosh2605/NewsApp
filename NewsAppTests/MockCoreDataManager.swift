//
//  MockCoreDataManager.swift
//  NewsAppTests
//
//  Created by Anup Ghosh on 28/01/25.
//


import Foundation
import Combine
import CoreData

@testable import NewsApp


class MockCoreNewsDataManager: CoreNewsDataManager {
    
    @Published var mockNewsPublisher: [ArticleEntity] = []
    
   

    private var mockStorage: [ArticleEntity] = []
    
    // Mocked managed object context for testing
    var managedObjectContext: NSManagedObjectContext
    
    // Initialize with a valid managed object context
    override init() {
        let container = NSPersistentContainer(name: "NewsDataContainer") // Replace with your actual container name
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Failed to load persistent stores: \(error)")
            }
        }
        managedObjectContext = container.viewContext
        super.init()
    }
    
    override func FetchNewsFromCoreData() {
        
        DispatchQueue.main.async {
            print("Fetching from Core Data: \(self.mockStorage.count) articles")  // Debugging log
            self.mockNewsPublisher = self.mockStorage
        }
    }
    
    override func addEntity(article: Article) {
        if isArticleAlreadyPresent(id: article.id) {
            return
        }
        
        // Use a valid managed object context for creating the entity
        let entityDescription = NSEntityDescription.entity(forEntityName: "ArticleEntity", in: managedObjectContext)!
        let entity = ArticleEntity(entity: entityDescription, insertInto: managedObjectContext)
        
        entity.id = article.id
        entity.title = article.title
        entity.author = article.author
        entity.desc = article.description
        entity.url = article.url
        entity.urlToImage = article.urlToImage
        
        mockStorage.append(entity)
        
        // Notify subscribers of the updated mock data
        DispatchQueue.main.async {
            self.mockNewsPublisher = self.mockStorage
        }
    }
    
    override func isArticleAlreadyPresent(id: String) -> Bool {
        return mockStorage.contains(where: { $0.id == id })
    }
}
