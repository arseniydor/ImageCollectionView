//
//  ImagesCollectionViewController.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 13.04.2022.
//

import SnapKit
import UIKit

class ImagesCollectionViewController: UIViewController {

    // MARK: Properities

    private let imagesCount: Int = 140
    private let itemsCountInLine: CGFloat = 7
    private let itemsCountInColumn: CGFloat = 10
    private let itemsPadding: CGFloat = 2
    private let imageManager = ImageManager.shared

    // MARK: UI Views

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: itemsPadding, left: itemsPadding, bottom: itemsPadding, right: itemsPadding)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        return collectionView
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
        addObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    // MARK: Initialization functions
    
    private func layoutUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentChangedNotification),
            name: .imagesCollectionViewUpdate,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentChangedNotification),
            name: .imagesAddedCollectionView,
            object: nil)
    }

    private func loadData() {
        imageManager.downloadImages(imagesCount: imagesCount) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error: error)
            }
        }
    }
    
    private func updateCollectionView() {
        self.collectionView.reloadData()
    }

    private func showError(error: NetworkError) {
        self.showAlert(title: "Ошибка", message: error.errorDescription)
    }
}

// MARK: - Notification handlers

extension ImagesCollectionViewController {
    @objc
    func contentChangedNotification(_ notification: Notification!) {
        updateCollectionView()
    }
}

// MARK: Bar buttons action

extension ImagesCollectionViewController {
    @objc
    private func didTapAddBarButton() {
        imageManager.addNewImage { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error: error)
            }
        }
    }

    @objc
    private func didTapReloadBarButton() {
        imageManager.clearImages()
        loadData()
    }
}

// MARK: UICollectionView delegate and datasource

extension ImagesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageManager.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let currentItem = imageManager.images[indexPath.row]
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
