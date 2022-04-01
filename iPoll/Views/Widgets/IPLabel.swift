//
//  IPLabel.swift
//  iPoll
//
//  Created by Evans Owamoyo on 14.03.2022.
//

import Foundation
import UIKit

class IPLabel: UILabel {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(_ text: String,
                     textColor: UIColor? = Constants.Colors.darkBlue,
                     font: UIFont? = Constants.appFont
    ) {
        self.init(frame: CGRect.zero)
        self.text = text
        self.textColor = textColor
        self.font = font
    }
}
