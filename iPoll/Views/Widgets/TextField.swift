//
//  TextField.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class TextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateUI()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("This class does not support NSEncoding")
    }
    
    func updateUI() {
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 6
        layer.borderWidth = 1.0
        
        // height constraint
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 51).isActive = true
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
}
