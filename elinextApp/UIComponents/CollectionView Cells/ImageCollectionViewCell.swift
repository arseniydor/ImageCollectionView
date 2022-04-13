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
    }

    private func styleUI() {
        backgroundColor = .clear
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
    }
    
    public func configure(image: UIImage?) {
        imageView.image = image
    }
}
