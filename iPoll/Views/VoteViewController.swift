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
        label.isSkeletonable = true
        return label
    }()
    
    private var authorLabel: IPLabel = {
        let label = IPLabel("", font: Constants.appFont?.withSize(18))
        label.isSkeletonable = true
        return label
    }()
    
    private var timeLabel: IPLabel = {
        let label = IPLabel("", font: Constants.appFont?.withSize(18))
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var chooseColorBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.setTitle("Choose Color", for: .normal)
        button.tintColor = poll?.color?.lighter() ?? .systemBlue
        button.setTitleColor(poll?.color?.darker(componentDelta: 0.2), for: .normal)
        if #available(iOS 14.0, *) {
            button.addTarget(self, action: #selector(onChooseColor(_:)), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        return button
    }()
    
    private var optionsTableView: UITableView = {
        let table = UITableView()
        table.estimatedRowHeight = 56
        table.rowHeight = UITableView.automaticDimension
        table.register(VoteOptionCell.self,
                       forCellReuseIdentifier: Constants.CellIdentifiers.voteOption)
        table.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.voteCustomSettings)
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
    
    @available(iOS 14.0, *)
    @objc func onChooseColor(_ sender: UIButton) {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
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
        view.addSubview(authorLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(10)
            make.top.equalTo(view).offset(90)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel)
        }
        
        optionsTableView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view).inset(10)
            make.top.equalTo(authorLabel.snp.bottom).offset(27)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension VoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.voteOption,
                                                            for: indexPath) as? VoteOptionCell,
                   let poll = poll {
                    cell.delegate = self
                    if let option = poll.options?[indexPath.row] {
                        cell.updateCell(optionTitle: option.title,
                                        optionId: option.id,
                                        isAnonymous: poll.isAnonymous,
                                        voteCount: option.votesId.count,
                                        totalCount: poll.totalVotes,
                                        color: poll.color) { optionId in
                            let viewController = VotersViewController(poll: poll,
                                                                      pollOption:
                                                                        poll.options!.first { $0.id == optionId}!)
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    }
                    return cell
                } else {
                    return UITableViewCell()
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.voteCustomSettings)
                cell?.textLabel?.text = "Choose Custom Color"
                cell?.accessoryView = chooseColorBtn as UIView
                return cell ?? UITableViewCell()
            default:
                fatalError("Only two sections should be provided for VoteViewController")
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return poll?.options?.count ?? 0
            case 1:
                return 1
            default:
                fatalError("numberOfRowsInSection should be only for two sections")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Poll Options"
        } else if section == 1 {
            return "Your Poll Custom Settings"
        }
        return nil
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
        self.poll = self.poll?.copyWith(poll) ?? poll
        titleLabel.text = poll.title
        let authorName = poll.author?.name ?? "Anonymous"
        authorLabel.text = "Created by: \(authorName)"
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

// MARK: - UIColorPickerViewControllerDelegate
extension VoteViewController: UIColorPickerViewControllerDelegate {
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        guard let poll = poll else { return }
        voteManager.persistPoll(poll)
        optionsTableView.reloadData()
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController,
                                   didSelect color: UIColor,
                                   continuously: Bool) {
        self.poll?.color = color
        chooseColorBtn.setTitleColor(color.darker(componentDelta: 0.2), for: .normal)
        chooseColorBtn.tintColor = color.lighter()
    }
}
