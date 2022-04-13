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
    
    public func retrieveImages(count: Int, completion: @escaping (Result<[UIImage?], NetworkError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let downloadGroup = DispatchGroup()
            var images: [UIImage?] = []
            for _ in 1 ... count {
                downloadGroup.enter()
                self.retrieveImage { result in
                    switch result {
                    case let .success(image):
                        images.append(image)
                        downloadGroup.leave()
                    case let .failure(error):
                        completion(.failure(error))
                        downloadGroup.leave()
                        return
                    }
                }
            }
            downloadGroup.wait()
            DispatchQueue.main.async {
                completion(.success(images))
            }
        }
    }

    public func retrieveImage(completion: @escaping (Result<UIImage?, NetworkError>) -> Void) {
        networkService.fetchData(from: URL(string: imageLoadUrl)) { result in
            switch result {
            case let .success(data):
                completion(.success(UIImage(data: data)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
