//
//  PollTableViewCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit

class PollTableViewCell: UITableViewCell {

    var title: String? {
        didSet {
            pollLabel.text = title
        }
    }

    lazy var mainView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor(hexString: "#CCDBFD")
        view.layer.borderColor = UIColor(hexString: "#ABC4FF").cgColor
        view.layer.cornerRadius = 8
        return view
    }()

    lazy var pollLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#052161")
        label.font = Constants.appFont
        label.numberOfLines = 0
        return label
    }()

    lazy var arrow: UIImageView = {
       let image = UIImage(systemName: "chevron.right")
        let view = UIImageView(image: image)
        view.tintColor = UIColor(hexString: "#052161")
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Constants.Colors.bgBlue
        mainView.addSubview(pollLabel)
        mainView.addSubview(arrow)
        contentView.addSubview(mainView)
        
        mainView.snp.makeConstraints { make in
            make.left.right.equalTo(contentView).inset(2)
            make.top.bottom.equalTo(contentView).inset(5)
        }
        arrow.snp.makeConstraints { make in
            make.centerY.equalTo(mainView)
            make.right.equalTo(mainView).offset(-14)
            make.width.greaterThanOrEqualTo(12)
        }
        pollLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(mainView).inset(13)
            make.right.lessThanOrEqualTo(mainView).offset(-12)
            make.left.equalTo(mainView).offset(10)
        }
    }
}
