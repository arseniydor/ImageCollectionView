//
//  ImageModel.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 14.04.2022.
//

import Foundation
import UIKit

public enum ImageLoadStatus {
    case loading
    case downloaded
    case failed
}

public class ImageModel {
    public var statusImage: ImageLoadStatus = .loading
    public var image: UIImage? = nil
    
    init() { }
    
    init(status: ImageLoadStatus, image: UIImage?) {
        self.statusImage = status
        self.image = image
    }
}
