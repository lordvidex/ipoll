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
    
    @UsesAutoLayout
    var mainView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor(hexString: "#CCDBFD")
        view.layer.borderColor = UIColor(hexString: "#ABC4FF").cgColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    @UsesAutoLayout
    var pollLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#052161")
        label.font = Constants.appFont
        label.numberOfLines = 0
        return label
    }()
    
    @UsesAutoLayout
    var arrow: UIImageView = {
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
        
        mainView.addSubview(pollLabel)
        mainView.addSubview(arrow)
        contentView.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            arrow.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -14),
            arrow.widthAnchor.constraint(greaterThanOrEqualToConstant: 12),
            
            pollLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
            pollLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrow.leadingAnchor, constant: -12),
            pollLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 13),
            pollLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -13)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
