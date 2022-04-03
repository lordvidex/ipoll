//
//  PollOptionCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import UIKit
import SnapKit
import SkeletonView

protocol VoteOptionCellDelegate: AnyObject {
    func didClickOption(_ cell: VoteOptionCell, with id: String?)
}

class VoteOptionCell: UITableViewCell {
    private var totalCount = 1
    private var voteCount = 0
    private var optionId: String?
    private var progressConstraint: NSLayoutConstraint?
    public weak var delegate: VoteOptionCellDelegate?

    private var mainView: UIButton = {
        let view = UIButton()
        view.isSkeletonable = true
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = Constants.Colors.borderBlue?.cgColor
        view.backgroundColor = Constants.Colors.bgBlue
        view.addTarget(VoteOptionCell.self, action: #selector(onVotePressed), for: .touchUpInside)
        return view
    }()

    private var progressView: UIView = {
        let view = UIView()
        view.isSkeletonable = true
        view.layer.cornerRadius = 6
        view.backgroundColor = Constants.Colors.lightBlue
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
        mainView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
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

    func updateCell(optionTitle: String, optionId: String, voteCount: Int = 0, totalCount: Int = 1) {
        self.voteCount = voteCount
        self.totalCount = totalCount
        self.optionId = optionId
        optionLabel.text = optionTitle
        voteCountLabel.text = "\(voteCount)"
        DispatchQueue.main.async {
            self.updateProgress()
        }

    }

    func updateProgress() {
        let ratio = Double(voteCount) / Double(totalCount == 0 ? 1 : totalCount)
        self.progressConstraint?.isActive = false
        self.progressConstraint = progressView.widthAnchor.constraint(equalTo: self.mainView.widthAnchor, multiplier: ratio)
        self.progressConstraint?.isActive = true
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [self] in
            self.layoutIfNeeded()
        }
    }

    @objc private func onVotePressed() {
        delegate?.didClickOption(self, with: optionId)
    }
}
