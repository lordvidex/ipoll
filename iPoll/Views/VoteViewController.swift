//
//  VoteViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import UIKit
import SkeletonView

class VoteViewController: UIViewController {
    
    // MARK: - Properties
    private var poll: Poll?
    public var pollId: String?
    private let voteManager = VoteManager()
    
    // MARK: - UI
    private var titleLabel: IPLabel = {
        let label = IPLabel("", font: Constants.appFont?.withSize(24))
        return label
    }()
    
    private var optionsTableView: UITableView = {
        let table = UITableView()
        table.estimatedRowHeight = 56
        table.rowHeight = UITableView.automaticDimension
        table.register(VoteOptionCell.self,
                       forCellReuseIdentifier: Constants.CellIdentifiers.voteOption)
        table.allowsSelection = false
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.alwaysBounceVertical = false
        return table
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if poll == nil {
            showLoading()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        voteManager.closeSocket()
    }
    
    func showLoading() {
        optionsTableView.isSkeletonable = true
        optionsTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: Constants.Colors.lightBlue!,
                                                                           secondaryColor: .white),
                                                      transition: .crossDissolve(1))
    }
    
    func hideLoading() {
        optionsTableView.stopSkeletonAnimation()
        self.view.hideSkeleton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        voteManager.delegate = self
        optionsTableView.dataSource = self
        self.view.backgroundColor = Constants.Colors.bgBlue
        if pollId != nil {
            voteManager.fetchPoll(pollId!)
        }
        
        view.addSubview(titleLabel)
        view.addSubview(optionsTableView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(10)
            make.top.equalTo(view).offset(90)
        }
        
        optionsTableView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view).inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(27)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension VoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.voteOption,
                                                    for: indexPath) as? VoteOptionCell,
           let poll = poll {
            cell.delegate = self
            if let option = poll.options?[indexPath.row] {
                cell.updateCell(optionTitle: option.title,
                                optionId: option.id,
                                voteCount: option.votesId.count,
                                totalCount: poll.totalVotes)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        poll?.options?.count ?? 0
    }
    
}

// MARK: - VoteManagerDelegate
extension VoteViewController: VoteManagerDelegate {
    func didFail(_ voteManager: VoteManager, sender: IPAction, with error: IPollError) {
        hideLoading()
        
        showErrorAlert(title: "Vote Error",
                       with: "An error occured while voting: \n \(error.message)",
                       addBackButton: sender == .fetch,
                       addOkButton: poll != nil)
    }
    
    func didReceivePoll(_ voteManager: VoteManager, sender: IPAction, poll: Poll) {
        self.poll = poll
        titleLabel.text = poll.title
        hideLoading()
        optionsTableView.reloadData()
    }
}

// MARK: - SkeletonTableViewDataSource
extension VoteViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView,
                                cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        Constants.CellIdentifiers.voteOption
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        poll?.options?.count ?? 4
    }
}

// MARK: - VoteOptionCellDeletate
extension VoteViewController: VoteOptionCellDelegate {
    func didClickOption(_ cell: VoteOptionCell, with id: String?) {
        if let id = id, let poll = poll {
            showLoading()
            voteManager.vote(pollId: poll.id, optionId: id)
        }
    }
    
}
