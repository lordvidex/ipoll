//
//  VotersTableViewCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.05.2022.
//

import UIKit

class VotersTableViewCell: UITableViewCell {
    private var id: String?
    private var name: String?
    private static var avatarHeight = 30
    
    private var displayName: String {
        // return name
        if let name = name, !name.isEmpty {
            return name
        } else if let id = id {
            return replaceMiddle(of: id, withCharacter: "*", offset: 3)
        } else {
            return "Anonymous"
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        print("Init with style and reuseIdentifier")
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder is not implemented in VotersTableViewCell")
    }
    
    // MARK: UIViews
    private var avatar: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.darkBlue
        view.frame = CGRect(x: 0, y: 0, width: avatarHeight, height: avatarHeight)
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    private var titleLabel: IPLabel = {
        let lbl = IPLabel()
        lbl.textAlignment = .left
        return lbl
    }()
    
    private var firstLetterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = label.font.withSize(24)
        return label
    }()
    
    private func setupViews() {
        avatar.addSubview(firstLetterLabel)
        contentView.addSubview(avatar)
        contentView.addSubview(titleLabel)
        
        firstLetterLabel.snp.makeConstraints { make in
            make.center.equalTo(avatar)
        }
        
        avatar.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.height.width.equalTo(VotersTableViewCell.avatarHeight)
            make.left.equalTo(contentView).inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(avatar.snp.right).offset(20)
            make.right.equalTo(contentView)
        }
        
        updateViews()
    }
    
    private func updateViews() {
        titleLabel.text = displayName
        firstLetterLabel.text = String(displayName.prefix(1))
    }
    
    public func build(id: String?, name: String?) {
        self.id = id
        self.name = name
        updateViews()
    }
    
    func replaceMiddle(of text: String, withCharacter character: String, offset: Int) -> String {
        var count = max(text.count - 2 * offset, 0) // catch negative cases for short strings
        let startIndex: String.Index
        let endIndex: String.Index
        if count == 0 {
            count = text.count
            startIndex = text.startIndex
            endIndex = text.endIndex
        } else {
            startIndex = text.index(text.startIndex, offsetBy: offset)
            endIndex = text.index(text.endIndex, offsetBy: -1 * offset)
        }
        let replacement = String(repeating: character, count: count)
        return text.replacingCharacters(in: startIndex..<endIndex, with: replacement)
    }
}
