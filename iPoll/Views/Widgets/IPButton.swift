//
//  Button.swift
//  iPoll
//
//  Created by Evans Owamoyo on 01.03.2022.
//

import UIKit

class IPButton: UIButton {

    private var cornerRadius: CGFloat = 9
    private var height: CGFloat = 50
    private var width: CGFloat?
    private var color: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("Button has no coder")
    }

    convenience init(
        text: String?,
        cornerRadius: CGFloat? = nil,
        height: CGFloat? = nil,
        width: CGFloat? = nil,
        backgroundColor: UIColor? = Constants.Colors.darkBlue,
        textColor: UIColor? = nil
    ) {
        self.init(frame: CGRect.zero)
        self.width = width
        self.color = backgroundColor

        if let text = text {
            setTitle(text, for: .normal)
        }

        if let textColor = textColor {
            setTitleColor(textColor, for: .normal)
        }

        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }

        if let height = height {
            self.height = height
        }

        titleLabel?.font = Constants.appFont!.withSize(18)
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateUI()
    }

    func updateUI() {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        backgroundColor = color
        
        snp.makeConstraints { make in
            make.height.equalTo(height)
            if let width = width {
                make.width.equalTo(width)
            }
        }
        
    }

    func addRightIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel!.snp.right).offset(10)
            make.centerY.equalTo(titleLabel!)
            make.width.height.equalTo(15)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .gray : color
        }
    }
}
