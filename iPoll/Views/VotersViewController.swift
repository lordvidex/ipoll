//
//  VotersViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.05.2022.
//

import UIKit
import CloudKit

class VotersViewController: UIViewController {
    
    // MARK: private variables
    private let poll: Poll
    private var pollOption: PollOption
    private weak var networkService: NetworkService? = .shared
    
    private var votersCount: Int {
        pollOption.votesId.count
    }
    
    private var pollPercent: Double {
        (Double(votersCount * 100) / Double(poll.totalVotes == 0 ? 1 : poll.totalVotes)).rounded()
    }
    
    init(poll: Poll, pollOption: PollOption) {
        self.poll = poll
        self.pollOption = pollOption
        super.init(nibName: nil, bundle: nil)
        
        getVoters()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* gets the voters list with their names from the server */
    private func getVoters() {
        networkService?.getPollVoters(poll: poll.id,
                                      option: pollOption.id) { [weak self] result in
            switch result {
            case .success(let option):
                DispatchQueue.main.async {
                    self?.pollOption = option
                    self?.table.reloadData()
                }
            case .failure(let err):
                self?.showErrorAlert(title: err.message, addBackButton: true)
            }
        }
    }
    
    // MARK: - UIViews
    lazy var table: UITableView = {
        let view = UITableView()
        view.register(VotersTableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.voters)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = Constants.Colors.bgBlue
        view.allowsSelection = false
        return view
    }()
    
    lazy var tableHeader: UIView = {
        let optionLabel = IPLabel("\(pollOption.title) - \(pollPercent)%")
        let votesLabel = IPLabel("\(votersCount) votes")
        let view = UIView()
        view.addSubview(optionLabel)
        view.addSubview(votesLabel)
        optionLabel.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.centerY.equalTo(view)
        }
        votesLabel.snp.makeConstraints { make in
            make.right.equalTo(view)
            make.centerY.equalTo(view)
        }
        return view
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = Constants.Colors.bgBlue
        navigationItem.title = "\(poll.title) -> \(pollOption.title)"
        setupViews()
        super.viewDidLoad()
    }
    
    private func setupViews() {
        view.addSubview(table)
        if votersCount == 0 {
            table.setEmptyMessage("No one has voted this option yet...")
        }
        table.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(14)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension VotersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        votersCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.voters)
            as? VotersTableViewCell {
            let id = pollOption.votes?[indexPath.row].id ?? pollOption.votesId[indexPath.row]
            let name = pollOption.votes?[indexPath.row].name
            cell.build(id: id, name: name)

            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableHeader
    }
}

// MARK: - UITableViewDelegate
extension VotersViewController: UITableViewDelegate {
}
