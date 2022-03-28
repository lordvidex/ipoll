//
//  PollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit
import UIImageSymbols
import Toast_Swift

class PollViewController: UIViewController {
    
    // MARK: local variables
    var activeSegmentedControlIndex: Int = 0 {
        didSet {
            if activeSegmentedControlIndex < 3 {
                segmentedContol.selectedSegmentIndex = activeSegmentedControlIndex
            }
        }
    }
    
    private static let segmentItems = ["Visited Polls", "Participated Polls", "Created Polls"]
    
    weak var pollManager: PollManager! = .shared
    var polls: [Poll] = []
    
    
    // MARK: - UI Elements
    @UsesAutoLayout
    private var pollLabel: UILabel = {
        let label = UILabel()
        label.text = segmentItems[0]
        label.font = Constants.appFont?.withSize(24)
        return label
    }()
    
    @UsesAutoLayout
    private var joinPollBtn: IPButton = {
        let btn = IPButton(text: "Join a poll", cornerRadius: 6, height: 48, backgroundColor:  Constants.Colors.darkBlue)
        btn.addRightIcon(image: UIImage(systemName: "chevron.right")!)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(onJoinBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    @UsesAutoLayout
    private var fab: IPButton = {
        let btn = IPButton(
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
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    @UsesAutoLayout
    private var segmentedContol: UISegmentedControl = {
        let ctrl = UISegmentedControl(items: segmentItems)
        ctrl.layer.cornerRadius = 9
        ctrl.selectedSegmentTintColor = Constants.Colors.darkBlue
        ctrl.tintColor = Constants.Colors.lightBlue
        ctrl.selectedSegmentIndex = 0
        ctrl.addTarget(self, action: #selector(onTapSegmentedControl(_:)), for: .valueChanged)
        ctrl.sendActions(for: .valueChanged)
        ctrl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return ctrl
    }()
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        pollManager.delegate = self
        setupViews()
        pollManager.queryPolls()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorStyle = .none
    }
    
    private func setupViews() {
        // set navigation Items
        navigationItem.title = "Polls"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: tableView.isEditing ? .done : .edit, target: self, action: #selector(onEditBtnPressed))
        view.backgroundColor = Constants.Colors.bgBlue
        
        // set refresh control to tableView
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(onRefreshed), for: .valueChanged)
        tableView.refreshControl = control
        
        // add subviews
        view.addSubview(segmentedContol)
        view.addSubview(pollLabel)
        view.addSubview(joinPollBtn)
        view.addSubview(tableView)
        view.addSubview(fab)
        
        // define constraints
        
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
        //        pollManager.queryPolls()
        updatePolls()
    }
    
    private func updatePolls() {
        switch segmentedContol.selectedSegmentIndex {
            case 0:
                pollLabel.text = PollViewController.segmentItems[0]
                polls = pollManager?.visitedPolls ?? []
            case 1:
                pollLabel.text = PollViewController.segmentItems[1]
                polls = pollManager?.participatedPolls ?? []
            case 2:
                pollLabel.text = PollViewController.segmentItems[2]
                polls = pollManager?.createdPolls ?? []
            default:
                fatalError("segmentControl should have only 2 children")
                
        }
        tableView.reloadData()
    }
    
    @objc func onEditBtnPressed() {
        tableView.isEditing = !tableView.isEditing
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: tableView.isEditing ? .done : .edit, target: self, action: #selector(onEditBtnPressed))
        
    }
    
    @objc func onTapFab(_ sender: UIButton) {
        navigationController?.pushViewController(CreatePollViewController(), animated: true)
    }
    
    @objc func onJoinBtnClicked() {
        navigationController?.pushViewController(JoinPollViewController(), animated: true)
    }
    
    @objc func onRefreshed(sender: UIRefreshControl) {
        pollManager.queryPolls { [weak self] updated in
            if updated {
                self?.updatePolls()
            }
            DispatchQueue.main.async {
                sender.endRefreshing()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension PollViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "poll", for: indexPath) as? PollTableViewCell {
            cell.title = polls[indexPath.row].title
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let poll = polls[indexPath.row]
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            PollPreviewController(pollId: poll.id, pollTitle: poll.title)
        },actionProvider: { _ in
            
            let copyLink = UIAction(title: "Copy Link", image: .docOnDocFill) { [weak self] _ in
                UIPasteboard.general.string = "ipoll://poll?id=\(poll.id)"
                self?.view.makeToast("Link to Poll successfully copied to clipboard")
            }
            
            let copyCode = UIAction(title: "Copy Code", image: .number) { [weak self] _ in
                UIPasteboard.general.string = poll.id
                self?.view.makeToast("Code successfully copied to clipboard")
            }
            
            let qrCode = UIAction(title: "Share QR Code", image: .squareAndArrowUp ) { [weak self] _ in
                // image to share
                let image = QRGenerator.generatePollQR(poll: poll.id)?.resizeImageForShare(targetSize: CGSize(width: 100, height: 100))
                
                // set up activity view controller
                let imageToShare = [ image! ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                
                // so that iPads won't crash
                activityViewController.popoverPresentationController?.sourceView = self?.view
                
                // present the view controller
                self?.present(activityViewController, animated: true, completion: nil)
            }
            
            
            let menu = UIMenu(title: "", children: [copyLink, copyCode, qrCode])
            return menu
        })
        
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let voteViewController = VoteViewController()
        voteViewController.pollId = polls[indexPath.row].id
        navigationController?.pushViewController(voteViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = polls.remove(at: sourceIndexPath.row)
        polls.insert(moved, at: destinationIndexPath.row)
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

extension PollViewController: PollManagerDelegate {
    func finishedFetchingPolls(_ success: Bool) {
        DispatchQueue.main.async {
            self.updatePolls()
        }
    }
    
    
}
