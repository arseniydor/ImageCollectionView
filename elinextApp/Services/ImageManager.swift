//
//  ImageManager.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 14.04.2022.
//

import Foundation

public class ImageManager {
    init() {}

    static let shared = ImageManager()

    private let concurrentImageQueue = DispatchQueue(label: "imageQueue", attributes: .concurrent)
    private var unsafeImages: [ImageModel] = []

    public var images: [ImageModel] {
        var imagesCopy: [ImageModel] = []
        concurrentImageQueue.sync {
            imagesCopy = self.unsafeImages
        }
        return imagesCopy
    }
    
    public func addNewImage(completion: @escaping (NetworkError?) -> Void) {
        downloadImages(imagesCount: 1, completion: completion)
    }

    public func downloadImages(imagesCount: Int, completion: @escaping (NetworkError?) -> Void) {
        let imageService: ImageService = ImageService()
        var storedError: NetworkError? = nil
        let downloadGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        for _ in 1 ... imagesCount {
            downloadGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                let imageModel = ImageModel()
                imageService.retrieveImage { [weak self] result in
                    switch result {
                    case let .success(image):
                        imageModel.statusImage = image.statusImage
                        imageModel.image = image.image
                    case let .failure(error):
                        storedError = error
                        imageModel.statusImage = .failed
                    }
                    downloadGroup.leave()
                    self?.postContentUpdateNotification()
                }
                ImageManager.shared.putImage(imageModel)
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }

        downloadGroup.notify(queue: DispatchQueue.main) {
            completion(storedError)
        }
    }
    
    public func clearImages() {
        unsafeImages.removeAll()
    }

    private func putImage(_ photo: ImageModel) {
        concurrentImageQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.unsafeImages.append(photo)
            self.postContentAddedNotification()
        }
    }
    
    private func postContentAddedNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .imagesAddedCollectionView, object: nil)
        }
    }
    
    private func postContentUpdateNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .imagesCollectionViewUpdate, object: nil)
        }
    }
}
