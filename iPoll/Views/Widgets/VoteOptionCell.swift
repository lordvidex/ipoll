//
//  PollOptionCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import UIKit
import SnapKit

protocol VoteOptionCellDelegate: AnyObject {
    func didClickOption(_ cell: VoteOptionCell, with id: String?)
}

typealias NavigateToVotersViewCallback = (_ optionId: String) -> Void

class VoteOptionCell: UITableViewCell {
    private var totalCount = 1
    private var voteCount = 0
    private var optionId: String?
    private var color: UIColor?
    private var progressConstraint: NSLayoutConstraint?
    private var callback: NavigateToVotersViewCallback?
    public weak var delegate: VoteOptionCellDelegate?

    private lazy var mainView: UIButton = {
        let view = UIButton()
        view.isSkeletonable = true
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = color?.darker().cgColor ?? Constants.Colors.borderBlue?.cgColor
        view.backgroundColor = color?.lighter() ?? Constants.Colors.bgBlue
        view.addTarget(self, action: #selector(onVotePressed), for: .touchUpInside)
        return view
    }()

    private lazy var progressView: UIButton = {
        let view = UIButton()
        view.isSkeletonable = true
        view.layer.cornerRadius = 6
        view.backgroundColor = color ?? Constants.Colors.lightBlue
        view.addTarget(self, action: #selector(onVotePressed), for: .touchUpInside)
        return view
    }()

    private var optionLabel: IPLabel = {
        let label = IPLabel("")
        label.isSkeletonable = true
        return label
    }()

    private var voteCountLabel: IPLabel = {
        let label = IPLabel("", font: Constants.appFont?.withSize(14))
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var viewVotersBtn: IPButton = {
        let btn = IPButton(text: nil, image: .eye?.withTintColor(.white))
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(gotoVotersVC), for: .touchUpInside)
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        self.isSkeletonable = true
        self.contentView.isSkeletonable = true
        self.contentView.backgroundColor = Constants.Colors.bgBlue

        mainView.addSubview(progressView)
        mainView.addSubview(optionLabel)
        mainView.addSubview(voteCountLabel)

        contentView.addSubview(mainView)
        contentView.addSubview(viewVotersBtn)
        
        viewVotersBtn.snp.makeConstraints { make in
            make.height.equalTo(contentView).inset(5)
            make.centerY.equalTo(contentView)
            make.width.equalTo(contentView.snp.height)
            make.right.equalTo(contentView)
        }
        
        mainView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(contentView)
                .inset(UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
            make.right.equalTo(viewVotersBtn.snp.left).offset(-5)
        }
        
        optionLabel.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(mainView).inset(12)
            make.right.equalTo(mainView).offset(-70)
        }
        voteCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(mainView)
            make.right.equalTo(mainView).offset(-12)
            make.left.greaterThanOrEqualTo(optionLabel.snp.right).priority(.medium)
        }

        progressView.snp.makeConstraints { make in
            make.height.left.top.bottom.equalTo(mainView)
        }
        progressConstraint = progressView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0)
        progressConstraint?.isActive = true
    }

    func updateCell(optionTitle: String,
                    optionId: String,
                    voteCount: Int = 0,
                    totalCount: Int = 1,
                    color: UIColor?,
                    onClick: NavigateToVotersViewCallback?
    ) {
        let dataChanged = voteCount != self.voteCount && totalCount != self.totalCount
        self.voteCount = voteCount
        self.totalCount = totalCount
        self.optionId = optionId
        self.color = color
        optionLabel.text = optionTitle
        voteCountLabel.text = "\(voteCount)"
        self.callback = onClick
        DispatchQueue.main.async {
            self.updateProgress(needAnimate: dataChanged)
        }

    }

    func updateProgress(needAnimate: Bool) {
        let ratio = Double(voteCount) / Double(totalCount == 0 ? 1 : totalCount)
        progressView.backgroundColor = color ?? progressView.backgroundColor
        mainView.backgroundColor = color?.lighter(componentDelta: 0.4) ?? mainView.backgroundColor
        mainView.layer.borderColor = color?.darker().cgColor ?? Constants.Colors.borderBlue?.cgColor
        
        self.progressConstraint?.isActive = false
        self.progressConstraint = progressView.widthAnchor
            .constraint(equalTo: self.mainView.widthAnchor,
                        multiplier: ratio)
        self.progressConstraint?.isActive = true
        if needAnimate {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [self] in
                self.layoutIfNeeded()
            }
        }
    }

    @objc private func onVotePressed() {
        delegate?.didClickOption(self, with: optionId)
    }
    
    @objc private func gotoVotersVC() {
        self.callback?(optionId!)
    }
}
