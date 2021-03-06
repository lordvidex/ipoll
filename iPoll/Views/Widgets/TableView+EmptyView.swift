//
//  TableView+EmptyView.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit

extension UITableView {
    
    /// Sets a background UILabel [View] with text of
    /// `message`
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: self.bounds.size.width,
                                                 height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    /// Removes `backgroundView` and resets `separatorStyle`
    func restore() {
        self.backgroundView = nil
//        self.separatorStyle = .singleLinere
    }
}
