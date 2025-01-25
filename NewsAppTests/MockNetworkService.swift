//
//  MockNetworkService.swift
//  NewsAppTests
//
//  Created by Anup Ghosh on 25/01/25.
//

import Foundation
import UIKit
@testable import NewsApp


class MockNetworkService: NetworkServiceProtocol {
    var mockData: Data?
    var mockError: NetworkError?
    
    func downloadData(urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else if let data = mockData {
            completion(.success(data))
        } else {
            completion(.failure(.unowned))
        }
    }
    
    func Decode<T: Codable>(data: Data?, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else if let mockData = mockData {
            do {
                let decodedObject = try JSONDecoder().decode(type, from: mockData)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodingError))
            }
        } else {
            completion(.failure(.unowned))
        }
    }
}
