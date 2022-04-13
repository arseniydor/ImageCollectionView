//
//  ImagesCollectionViewController.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 13.04.2022.
//

import SnapKit
import UIKit

class ImagesCollectionViewController: UIViewController {
    // MARK: Private

    private var service: ImageService = ImageService()
    private var images: [UIImage?] = []

    // MARK: ColletionView layout setup

    private let imagesCount: Int = 140
    private let itemsCountInLine: CGFloat = 7
    private let itemsCountInColumn: CGFloat = 10
    private let itemsPadding: CGFloat = 2

    // MARK: UI views

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: itemsPadding, left: itemsPadding, bottom: itemsPadding, right: itemsPadding)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        activityView.color = .red
        activityView.style = .large
        activityView.startAnimating()
        return activityView
    }()

    private lazy var addBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddBarButton))
        return button
    }()

    private lazy var reloadBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Reload all", style: .plain, target: self, action: #selector(didTapReloadBarButton))
        return button
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        configureNavBar()
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    private func layoutUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func configureNavBar() {
        navigationItem.leftBarButtonItem = addBarButton
        navigationItem.rightBarButtonItem = reloadBarButton
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
    }

    private func loadData() {
        startLoading()
        service.retrieveImages(count: imagesCount) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.images = images
                self.updateCollectionView()
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
    
    private func updateCollectionView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.stopLoading()
        }
    }
    
    private func showError(error: NetworkError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showAlert(title: "Ошибка", message: error.errorDescription)
            self.stopLoading()
        }
    }
}

// MARK: ActivityView Actions

extension ImagesCollectionViewController {
    private func startLoading() {
        self.reloadBarButton.isEnabled = false
        self.addBarButton.isEnabled = false
        self.activityIndicatorView.isHidden = false
    }
    
    private func stopLoading() {
        self.reloadBarButton.isEnabled = true
        self.addBarButton.isEnabled = true
        self.activityIndicatorView.isHidden = true
    }
}

// MARK: Bar buttons action

extension ImagesCollectionViewController {
    @objc
    private func didTapAddBarButton() {
        startLoading()
        service.retrieveImage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(image):
                self.images.append(image)
                self.updateCollectionView()
            case let .failure(error):
                self.showError(error: error)
            }
        }
    }

    @objc
    private func didTapReloadBarButton() {
        loadData()
    }
}

// MARK: UICollectionView delegate and datasource

extension ImagesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let currentItem = images[indexPath.row]
        cell.configure(image: currentItem)
        return cell
    }
}

// MARK: UICollectionViewLayout delegate

extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowWidth: CGFloat = UIScreen.main.bounds.width
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.size.height
        let itemWidth = (windowWidth - itemsPadding * 2 - (itemsCountInLine - 1) * itemsPadding) / itemsCountInLine
        let itemHeight = (safeAreaHeight - itemsPadding * 2 - (itemsCountInColumn - 1) * itemsPadding) / itemsCountInColumn
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemsPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemsPadding
    }
}
