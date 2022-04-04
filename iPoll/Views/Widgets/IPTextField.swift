//
//  IPTextField.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class IPTextField: UITextField {

    var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                layer.borderColor = borderColor.cgColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateUI()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateUI()
    }

    func updateUI() {
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 6
        layer.borderWidth = 1.0

        // height constraint
        self.snp.makeConstraints { make in
            make.height.equalTo(51)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
}
