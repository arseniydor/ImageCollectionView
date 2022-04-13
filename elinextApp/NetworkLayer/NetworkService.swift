//
//  NetworkService.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 13.04.2022.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalid URL"
        case .unableToComplete:
            return "Unable to complete your request"
        case .invalidResponse:
            return "Invalid response from the server"
        case .invalidData:
            return "The data received from the server was invalid"
        }
    }
}

public class NetworkService {
    
    public init() {}
    private let configuration: URLSessionConfiguration = .default
    private lazy var urlSession: URLSession = .init(configuration: configuration)
    
    public func fetchData(from url: URL?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request: URLRequest = .init(url: url)
        
        let task = self.urlSession.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      completion(.failure(.invalidResponse))
                 return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
}
