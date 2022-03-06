//
//  PollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit

class PollViewController: UIViewController {
    // MARK: local variables
    var polls: [Poll] = [
        Poll(id: "sdfdsf", title:  "asdfdsahgdslge ergbsagbdsg dsagfidasgbdsg dsfgasdgdsag reg erwgaewtfaseg rgargars grdsgrdgrsgre gergerger gergergerwger gsdfgsrdg ", finished: false, startTime: Date(), endTime: nil, options: [
            PollOption(id: "sdf", title: "yes", votes: []),
            PollOption(id: "sdfg", title: "no", votes: [])
        ]),
        Poll(id: "sdfd",title: "Hello", finished: false, startTime: Date(), endTime: Date(), options: [])]
    
    // MARK: - UI Elements
    
    @UsesAutoLayout
    private var pollLabel: UILabel = {
        let label = UILabel()
        label.text = "Active Polls"
        label.font = Constants.appFont?.withSize(24)
        return label
    }()
    
    @UsesAutoLayout
    private var joinPollBtn: Button = {
        let btn = Button(text: "Join a poll", cornerRadius: 6, height: 48, backgroundColor: UIColor(named: Constants.Colors.darkBlue))
        btn.addRightIcon(image: UIImage(systemName: "chevron.right")!)
        btn.tintColor = .white
        return btn
    }()
    
    @UsesAutoLayout
    private var fab: Button = {
        let btn = Button(
            text: "Create Poll",
            cornerRadius: 25,
            height: 50,
            width: 122,
            textColor: .white
        )
        btn.addTarget(self, action: #selector(onTapFab(_:)), for: .touchUpInside)
        return btn
    }()
    
    @UsesAutoLayout
    fileprivate var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = UITableView.automaticDimension
        table.register(PollTableViewCell.self, forCellReuseIdentifier: "poll")
        table.estimatedRowHeight = 50
        table.separatorStyle = .none
        return table
    }()
    
    @UsesAutoLayout
    private var segmentedContol: UISegmentedControl = {
        let ctrl = UISegmentedControl(items: ["Active Polls", "Past Polls", "My Polls"])
        ctrl.layer.cornerRadius = 9
        ctrl.selectedSegmentTintColor = UIColor(named: Constants.Colors.darkBlue)
        ctrl.tintColor = UIColor(named: Constants.Colors.lightBlue)
        ctrl.selectedSegmentIndex = 0
        ctrl.addTarget(self, action: #selector(onTapSegmentedControl(_:)), for: .valueChanged)
        ctrl.sendActions(for: .valueChanged)
        ctrl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return ctrl
    }()
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorStyle = .none
    }
    
    private func setupViews() {
        navigationItem.title = "Polls"
        view.backgroundColor = UIColor(named: Constants.Colors.bgBlue)
        
        // TODO: add other subviews
        view.addSubview(segmentedContol)
        view.addSubview(pollLabel)
        view.addSubview(joinPollBtn)
        view.addSubview(tableView)
        view.addSubview(fab)
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            segmentedContol.heightAnchor.constraint(equalToConstant: 32),
            segmentedContol.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            segmentedContol.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            segmentedContol.topAnchor.constraint(equalTo: guide.topAnchor),
            
            pollLabel.topAnchor.constraint(equalTo: segmentedContol.bottomAnchor, constant: 30),
            pollLabel.leadingAnchor.constraint(equalTo: segmentedContol.leadingAnchor),
            pollLabel.trailingAnchor.constraint(equalTo: segmentedContol.trailingAnchor),
            
            joinPollBtn.leadingAnchor.constraint(equalTo: pollLabel.leadingAnchor),
            joinPollBtn.trailingAnchor.constraint(equalTo: pollLabel.trailingAnchor),
            joinPollBtn.topAnchor.constraint(equalTo: pollLabel.bottomAnchor, constant: 19),
            
            tableView.leadingAnchor.constraint(equalTo: joinPollBtn.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: joinPollBtn.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: joinPollBtn.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            fab.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -31),
            fab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func onTapSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                pollLabel.text = "Active Polls"
            case 1:
                pollLabel.text = "Past Polls"
            case 2:
                pollLabel.text = "My Polls"
            default:
                fatalError("segmentControl should have only 2 children")
                
        }
    }
    
    @objc func onTapFab(_ sender: UIButton) {
        navigationController?.pushViewController(CreatePollViewController(), animated: true)
    }
}

// MARK: - UITableViewDelegate
extension PollViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "poll", for: indexPath) as? PollTableViewCell {
            cell.title = polls[indexPath.row].title
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: navigate to details screen
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let from = polls[sourceIndexPath.row]
        polls[sourceIndexPath.row] = polls[destinationIndexPath.row]
        polls[destinationIndexPath.row] = from
        tableView.reloadRows(at: [sourceIndexPath, destinationIndexPath], with: .top)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

// MARK: - UITableViewDataSource
extension PollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if polls.count == 0 {
            self.tableView.setEmptyMessage("Empty List of Polls")
        } else {
            self.tableView.restore()
        }
        
        return polls.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
}
