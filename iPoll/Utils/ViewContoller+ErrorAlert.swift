//
//  ViewContoller+ErrorAlert.swift
//  iPoll
//
//  Created by Evans Owamoyo on 11.04.2022.
//

import UIKit

extension UIViewController {
    
    func showErrorAlert(title: String? = nil,
                        with message: String? = nil,
                        addBackButton: Bool,
                        addOkButton: Bool = true) {
        let alert = UIAlertController(title: title ?? "Alert",
                                      message: "An error occured while voting: \n \(message ?? "")",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        let backAction = UIAlertAction(title: "Exit", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        if addOkButton {
            alert.addAction(okAction) // simply dismisses alertAction
        }
        
        if addBackButton {
            alert.addAction(backAction) // returns User to previous screen
        }
        
        present(alert, animated: true)
    }
}
