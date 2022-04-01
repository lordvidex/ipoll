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

        heightAnchor.constraint(equalToConstant: height).isActive = true
        if let width = self.width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }

    func addRightIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        let length = CGFloat(15)
        titleEdgeInsets.right += length

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .gray : color
        }
    }
}
