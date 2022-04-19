//
//  ImageCollectionViewCell.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 13.04.2022.
//

import UIKit
import SnapKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        activityView.color = .black
        activityView.style = .medium
        return activityView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
        styleUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func styleUI() {
        backgroundColor = .clear
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
    }
    
    public func configure(image: ImageModel?) {
        guard let image = image else {
            imageView.image = nil
            activityIndicatorView.stopAnimating()
            return
        }
        switch image.statusImage {
        case .downloaded:
            activityIndicatorView.stopAnimating()
            imageView.image = image.image
        case .failed:
            activityIndicatorView.stopAnimating()
            imageView.image = UIImage(named: "errorImage")
        case .loading:
            imageView.image = nil
            activityIndicatorView.startAnimating()
        }
    }
}
