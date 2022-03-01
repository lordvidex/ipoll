//
//  Button.swift
//  iPoll
//
//  Created by Evans Owamoyo on 01.03.2022.
//

import UIKit

class Button: UIButton {
    
    private var cornerRadius: CGFloat = 9
    private var height: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Button has no coder")
    }
    
    convenience init(cornerRadius: CGFloat? = nil, height: CGFloat?) {
        self.init(frame: CGRect.zero)
        
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
        if let height = height {
            self.height = height
        }
    }
    
    func updateUI() {
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = UIColor(hexString: "#16191D").cgColor
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
