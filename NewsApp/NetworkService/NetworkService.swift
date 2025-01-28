//
//  NetworkService.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import Foundation


protocol NetworkServiceProtocol {
    func downloadData(urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func Decode<T: Codable>(data: Data?, type: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
}


enum NetworkError : Error {
    case dataError
    case badURL
    case unowned
    case decodingError
    case networkError
}


class NetworkService :NetworkServiceProtocol{
    
    
    static let instace = NetworkService()
    
    
    private init(){}
    
    
    // function to download data from the API
    func downloadData(urlString : String,completion : @escaping(Result<Data,NetworkError>) -> Void){
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.dataError))
                }
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            }
        }.resume()
    }
    
    
    // Decode the data based on the data model
    func Decode<T:Codable>(data: Data?,type : T.Type,completion : @escaping(Result<T,NetworkError>) -> Void) {
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(.decodingError))
            }
            return
        }
        
        do {
            let result = try JSONDecoder().decode(type, from: data)
            DispatchQueue.main.async {
                completion(.success(result))
            }
        } catch {
            print("Error in decoding \(error)")
            DispatchQueue.main.async {
                completion(.failure(.decodingError))
            }
        }
    }
}

