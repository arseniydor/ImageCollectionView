//
//  Extension+UIViewController.swift
//  elinextApp
//
//  Created by Arseniy Dorogin on 13.04.2022.
//

import UIKit

extension UIViewController {
    func showAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .cancel))
        self.present(alert, animated: true)
    }
}
