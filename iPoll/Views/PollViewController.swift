import UIKit
import UIImageSymbols
import Toast_Swift

class PollViewController: UIViewController {

    // MARK: local variables
    var activeSegmentedControlIndex: Int = 0 {
        didSet {
            if activeSegmentedControlIndex < 3 {
                segmentedControl.selectedSegmentIndex = activeSegmentedControlIndex
            }
        }
    }

    private lazy var segmentItems: [String] = {
        ["Visited Polls", "Participated Polls", "Created Polls"]
    }()

    var pollManager: PollManager! = .shared 
    var polls: [Poll] = []

    // MARK: - UI Elements
    private lazy var pollLabel: UILabel = {
        let label = UILabel()
        label.text = segmentItems.first
        label.font = Constants.appFont?.withSize(24)
        return label
    }()

    private lazy var joinPollBtn: IPButton = {
        let btn = IPButton(text: "Join a poll", cornerRadius: 6, height: 48, backgroundColor: Constants.Colors.darkBlue)
        btn.addRightIcon(image: UIImage(systemName: "chevron.right")!)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(onJoinBtnClicked), for: .touchUpInside)
        return btn
    }()

    private lazy var fab: IPButton = {
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

    fileprivate var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = UITableView.automaticDimension
        table.register(PollTableViewCell.self, forCellReuseIdentifier: "poll")
        table.estimatedRowHeight = 80
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let ctrl = UISegmentedControl(items: segmentItems)
        ctrl.layer.cornerRadius = 9
        ctrl.selectedSegmentTintColor = Constants.Colors.darkBlue
        ctrl.tintColor = Constants.Colors.lightBlue
        ctrl.selectedSegmentIndex = 0
        ctrl.addTarget(self, action: #selector(onTapSegmentedControl(_:)), for: .valueChanged)
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
        
        tableView.refreshControl?.beginRefreshing()
        pollManager.fetchVisitedPolls() // local
        pollManager.fetchRemotePolls()  // remote
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PeriodicManager.shared.startTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorStyle = .none
    }

    private func setupViews() {
        // set navigation Items
        setupNavbarItems()
        view.backgroundColor = Constants.Colors.bgBlue

        // set refresh control to tableView
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(onRefreshed), for: .valueChanged)
        tableView.refreshControl = control

        // add subviews
        view.addSubview(segmentedControl)
        view.addSubview(pollLabel)
        view.addSubview(joinPollBtn)
        view.addSubview(tableView)
        view.addSubview(fab)

        // define constraints

        let guide = view.safeAreaLayoutGuide
        segmentedControl.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.left.right.equalTo(view).inset(8)
            make.top.equalTo(guide)
        }
        pollLabel.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(30)
            make.left.right.equalTo(segmentedControl)
        }
        joinPollBtn.snp.makeConstraints({ make in
            make.left.right.equalTo(pollLabel)
            make.top.equalTo(pollLabel.snp.bottom).offset(19)
        })
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(joinPollBtn)
            make.bottom.equalTo(view)
            make.top.equalTo(joinPollBtn.snp.bottom).offset(10)
        }
        fab.snp.makeConstraints { make in
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(view).offset(-31)
        }
    }
    
    private func setupNavbarItems() {
        navigationItem.title = "Polls"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .gear, style: .plain, target: self, action: #selector(onSettingsPressed)),
            UIBarButtonItem(
                image: tableView.isEditing ? .checkmark : .pencil,
                style: tableView.isEditing ? .done : .plain,
            target: self,
            action: #selector(onEditBtnPressed))
        ]
    }

    @objc func onTapSegmentedControl(_ sender: UISegmentedControl) {
        //        pollManager.queryPolls()
        updatePolls()
    }

    private func updatePolls() {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                pollLabel.text = segmentItems[0]
                polls = pollManager?.visitedPolls ?? []
            case 1:
                pollLabel.text = segmentItems[1]
                polls = pollManager?.participatedPolls ?? []
            case 2:
                pollLabel.text = segmentItems[2]
                polls = pollManager?.createdPolls ?? []
            default:
                fatalError("segmentControl should have only 2 children")

        }
        tableView.reloadData()
    }

    @objc func onEditBtnPressed() {
        tableView.isEditing = !tableView.isEditing
        setupNavbarItems()
    }
    
    @objc func onSettingsPressed() {
        let alertVC = UIAlertController(title: "Settings", message: "", preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            // create an alert controller
            let pending = UIAlertController(title: "Logging out", message: nil, preferredStyle: .alert)

            // create an activity indicator
            let indicator = UIActivityIndicatorView(frame: pending.view.bounds)
            indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            pending.view.addSubview(indicator)
            indicator.isUserInteractionEnabled = false
            indicator.startAnimating()

            self?.present(pending, animated: true)
            if PersistenceService.shared.deleteAllPolls() {
                NetworkService.logout {
                    DispatchQueue.main.async {
                        pending.dismiss(animated: true)
                        alertVC.dismiss(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            Router.navigator?.setViewControllers([AuthViewController()], animated: false)
                        }
                    }
                }
            }
        }
        let viewDetailsAction = UIAlertAction(title: "My Details", style: .default) { [weak self] _ in
            alertVC.dismiss(animated: true)
            let detailsVC = UIAlertController(title: "My Details",
                                              message: "View / Edit your details \n ID: \(NetworkService.userId ?? "No ID")",
                                              preferredStyle: .alert)
            var textField: UITextField!
            detailsVC.addTextField { textfield in
                textField = textfield
                textfield.text = NetworkService.username
                textfield.leftViewMode = .always
                let label = UILabel()
                label.text = "Name: "
                label.font = label.font.withSize(14)
                label.textColor = Constants.Colors.darkBlue
                label.backgroundColor = Constants.Colors.lightBlue
                textfield.leftView = label
            }

            let saveBtn = UIAlertAction(title: "Save", style: .default) { _ in
                NetworkService.username = textField.text
                
                NetworkService.shared.setUser(id: nil, name: nil) { _ in
                    detailsVC.dismiss(animated: true)
                }
            }
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                detailsVC.dismiss(animated: true)
            }
            detailsVC.addAction(saveBtn)
            detailsVC.addAction(cancelBtn)
            self?.present(detailsVC, animated: true)
        }
        
        alertVC.addAction(logoutAction)
        alertVC.addAction(viewDetailsAction)
        alertVC.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in
            alertVC.dismiss(animated: true)
        }))
        
        present(alertVC, animated: true)
        
    }

    @objc func onTapFab(_ sender: UIButton) {
        gotoCreateVC()
    }

    @objc func onJoinBtnClicked() {
        navigationController?.pushViewController(JoinPollViewController(), animated: true)
    }

    @objc func onRefreshed(sender: UIRefreshControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            pollManager.fetchVisitedPolls()
            updatePolls()
            sender.endRefreshing()
        } else {
            pollManager.fetchRemotePolls { [weak self] updated in
                if updated {
                    self?.updatePolls()
                }
                DispatchQueue.main.async {
                    sender.endRefreshing()
                }
            }
        }
    }
    
    func gotoVoteVC(id: String) {
        let voteViewController = VoteViewController()
        voteViewController.pollId = id
        navigationController?.pushViewController(voteViewController, animated: true)
    }
    
    /// opens CreateViewController in [create] mode if id is `nil` otherwise
    /// opens CreateViewController in [edit] mode
    func gotoCreateVC(id: String? = nil) {
        let createVC = CreatePollViewController()
        if id != nil {
            createVC.pollId = id
        }
        navigationController?.pushViewController(createVC, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension PollViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "poll", for: indexPath) as? PollTableViewCell {
            cell.poll = polls[indexPath.row]
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let poll = polls[indexPath.row]
        var actions = [UIContextualAction]()
        
        let openAsParticipant: UIContextualAction = .simple(
            title: "Open", backgroundColor: .systemBlue, image: .envelopeOpen) {  [weak self] in
                self?.gotoVoteVC(id: poll.id)
            }
        
        let openAsEditor: UIContextualAction = .simple(title: "Open as Creator",
                                                       backgroundColor: .systemPurple,
                                                       image: .pencilCircle) { [weak self] in
            self?.gotoCreateVC(id: poll.id)
        }
        
        actions.append(openAsParticipant)
        if poll.authorId == NetworkService.userId {
            actions.append(openAsEditor)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let poll = polls[indexPath.row]
        var actions = [UIContextualAction]()
        
        let copyLink: UIContextualAction = .simple(title: "Copy Link",
                                                   backgroundColor: .systemPink,
                                                   image: .docOnDocFill) { [weak self] in
            UIPasteboard.general.string = "ipoll://poll?id=\(poll.id)"
            self?.view.makeToast("Link to Poll successfully copied to clipboard")
        }
        
        let copyCode: UIContextualAction = .simple(title: "Copy Code",
                                                   backgroundColor: .systemBrown,
                                                   image: .number) { [weak self] in
            UIPasteboard.general.string = poll.id
            self?.view.makeToast("Code successfully copied to clipboard")
        }
        
        let qrCode: UIContextualAction = .simple(title: "QR Code",
                                                 backgroundColor: .systemYellow,
                                                 image: .squareAndArrowUp) { [weak self] in
            let image = QRGenerator.generatePollQR(poll: poll.id)?
                .resizeImageForShare(targetSize: CGSize(width: 100, height: 100))
            let imageToShare = [ image! ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare,
                                                                  applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self?.view
            self?.present(activityViewController, animated: true, completion: nil)
        }
        // Append actions
        actions.append(copyLink)
        actions.append(copyCode)
        actions.append(qrCode)
       
        return UISwipeActionsConfiguration(actions: actions)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let poll = polls[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            PollPreviewController(pollId: poll.id, pollTitle: poll.title)
        }, actionProvider: { _ in
            let openAsParticipant = UIAction(title: "Open as participant", image: .envelopeOpen) { [weak self] _ in
                self?.gotoVoteVC(id: poll.id)
            }
            let openAsEditor = UIAction(title: "Open as creator", image: .pencilCircle) { [weak self] _ in
                self?.gotoCreateVC(id: poll.id)
            }
            var actionChildren = [openAsParticipant]

            if poll.authorId == NetworkService.userId { // created by this user
                actionChildren.append(openAsEditor)
            }
            let openAction = UIMenu(title: "Open ...",
                                    children: actionChildren)
            
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
                let image = QRGenerator.generatePollQR(poll: poll.id)?
                .resizeImageForShare(targetSize: CGSize(width: 100, height: 100))

                // set up activity view controller
                let imageToShare = [ image! ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare,
                                                                      applicationActivities: nil)

                // so that iPads won't crash
                activityViewController.popoverPresentationController?.sourceView = self?.view

                // present the view controller
                self?.present(activityViewController, animated: true, completion: nil)
            }

            return UIMenu(title: "", children: [openAction, copyLink, copyCode, qrCode])
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        gotoVoteVC(id: polls[indexPath.row].id)
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
            self.tableView.separatorStyle = .none
        }

        return polls.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

}

// MARK: - PollManagerDelegate
extension PollViewController: PollManagerDelegate {
    func finishedFetchingPolls(_ success: Bool) {
        DispatchQueue.main.async {
            if let refreshControl = self.tableView.refreshControl,
               refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            self.updatePolls()
        }
    }

}
