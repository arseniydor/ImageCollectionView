//
//  ImageService.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 13.04.2022.
//

import Foundation
import UIKit

public class ImageService {
    private let imageLoadUrl: String = "https://loremflickr.com/200/200"
    private let networkService: NetworkService = NetworkService()
    
    public init() {}
    
    public func retrieveImage(completion: @escaping (Result<ImageModel, NetworkError>) -> Void) {
        networkService.fetchData(from: URL(string: imageLoadUrl)) { result in
            switch result {
            case let .success(data):
                let image = UIImage(data: data)
                completion(.success(ImageModel(status: .downloaded, image: image)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
