//
//  CreatePollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class CreatePollViewController: UIViewController {
    
    fileprivate var pollManager = PollManager()
    fileprivate var pollCreateManager = PollCreateManager()
    
    // if pollId is not null then we are in editMode
    var pollId: String?
    private var editMode: Bool { pollId != nil }
    
    // MARK: - UI Views
    private lazy var pollTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Poll Title"
        label.textColor = Constants.Colors.darkBlue
        label.font = Constants.appFont?.withSize(18)
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var startTimePicker: UIDatePicker = {
        let pickerView = UIDatePicker(frame: .zero)
        pickerView.datePickerMode = .dateAndTime
        pickerView.addTarget(self, action: #selector(onStartTimeChanged), for: .valueChanged)
        pickerView.isSkeletonable = true
        return pickerView
    }()
    
    private lazy var endTimePicker: UIDatePicker = {
        let pickerView = UIDatePicker(frame: .zero)
        pickerView.datePickerMode = .dateAndTime
        pickerView.addTarget(self, action: #selector(onEndTimeChanged), for: .valueChanged)
        pickerView.isSkeletonable = true
        return pickerView
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Poll"
        label.font = Constants.appFont?.withSize(24)
        label.textColor = Constants.Colors.darkBlue
        label.isSkeletonable = true
        return label
    }()
    
    private lazy var hasTimeSwitch: UISwitch  = {
        let swtch = UISwitch(frame: .zero)
        swtch.setOn(pollCreateManager.hasTime, animated: false)
        swtch.addTarget(self, action: #selector(onHasTimeSwitchChanged), for: .valueChanged)
        swtch.isSkeletonable = true
        return swtch
    }()
    
    private lazy var anonymousSwitch: UISwitch = {
        let swtch = UISwitch()
        swtch.setOn(pollCreateManager.isVoterAnonymous, animated: false)
        swtch.addTarget(self, action: #selector(onAnonymousToggled), for: .valueChanged)
        swtch.isSkeletonable = true
        return swtch
    }()
    
    lazy var pollTitleTF: UITextField = {
        let tf = IPTextField()
        tf.text = "Hello World!"
        tf.isSkeletonable = true
        return tf
    }()
    
    private lazy var pollCreateBtn: UIButton = {
        let btn = IPButton(text: "Create poll", textColor: .white)
        btn.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        btn.isSkeletonable = true
        return btn
    }()
    
    private func sectionTitleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = Constants.appFont?.withSize(14)
        label.textColor = Constants.Colors.darkBlue
        label.isSkeletonable = true
        return label
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.hidesWhenStopped = true
        return loading
    }()
    
    private lazy var optionsTableView: UITableView = {
        let table = UITableView()
        table.register(UINib(nibName: Constants.CellIdentifiers.pollOption,
                             bundle: nil),
                       forCellReuseIdentifier: Constants.CellIdentifiers.pollOption)
        table.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.pollSetting)
        table.separatorStyle = .none
        table.allowsSelection = false
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        table.isSkeletonable = true
        return table
    }()
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        pollCreateManager.delegate = self
        pollManager.delegate = self
        
        loadingIndicator.stopAnimating()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !editMode {
            pollCreateManager.startTime = startTimePicker.date
            pollCreateManager.endTime = endTimePicker.date
        } else {
            pollManager.fetchPoll(with: pollId!)
            headerLabel.text = "Edit Poll"
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(usingGradient:
                    .init(baseColor: Constants.Colors.lightBlue!,
                          secondaryColor: .white),
                                              transition: .crossDissolve(1))
        }
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(headerLabel)
        view.addSubview(pollTitleLabel)
        view.addSubview(pollTitleTF)
        view.addSubview(optionsTableView)
        view.addSubview(pollCreateBtn)
        view.addSubview(loadingIndicator)
        
        let safeArea = view.safeAreaLayoutGuide
        
        headerLabel.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(safeArea).offset(20)
        }
        pollTitleTF.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.left.right.equalTo(headerLabel).inset(20)
            make.top.equalTo(headerLabel.snp.bottom).offset(40)
        }
        pollTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(pollTitleTF)
            make.bottom.equalTo(pollTitleTF.snp.top).offset(-5)
        }
        pollCreateBtn.snp.makeConstraints { make in
            make.left.right.equalTo(pollTitleTF)
            make.bottom.equalTo(view).offset(-26)
        }
        optionsTableView.snp.makeConstraints { make in
            make.left.right.equalTo(safeArea).inset(5)
            make.top.equalTo(pollTitleTF.snp.bottom).offset(30)
            make.bottom.equalTo(pollCreateBtn.snp.top).offset(-5)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    @objc func createPoll() {
        loadingIndicator.startAnimating() // loading
        
        // get variables
        let title = pollTitleTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasTime = pollCreateManager.hasTime
        let isAnonymousVoters = pollCreateManager.isVoterAnonymous
        let startTime = hasTime ? pollCreateManager.startTime : nil
        let endTime = hasTime ? pollCreateManager.endTime : nil
        
        let dto = PollDto(title: title,
                          options: pollCreateManager.options,
                          hasTimeLimit: hasTime,
                          isAnonymous: isAnonymousVoters,
                          startTime: startTime,
                          endTime: endTime)
        
        let closure: (Result<Poll, IPollError>) -> Void = { [weak self] result in
            switch result {
                case .success:
                    print("Success")
                    DispatchQueue.main.async {
                        let pollVC = PollViewController()
                        pollVC.activeSegmentedControlIndex = 2
                        self?.navigationController?.viewControllers = [pollVC]
                    }
                case .failure(let err):
                    self?.showErrorAlert(title: "An Error Occured",
                                         with: "Failure Creating/Editing Poll \n\(err)",
                                         addBackButton: false,
                                         addOkButton: true)
                    
            }
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
        }
        
        if editMode {
            pollManager.editPoll(id: pollId!, pollDto: dto, completion: closure)
        } else {
            pollManager.createPoll(pollDto: dto, completion: closure)
        }
    }
    
    @objc func onHasTimeSwitchChanged(_ sender: UISwitch) {
        pollCreateManager.hasTime = sender.isOn
    }
    
    @objc func onStartTimeChanged(_ sender: UIDatePicker) {
        pollCreateManager.startTime = sender.date
    }
    @objc func onEndTimeChanged(_ sender: UIDatePicker) {
        pollCreateManager.endTime =  sender.date
    }
    @objc func onAnonymousToggled(_ sender: UISwitch) {
        pollCreateManager.isVoterAnonymous = sender.isOn
    }
    
}

// MARK: - UITableViewDataSource
extension CreatePollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pollCreateManager.options.count
        } else if section == 1 {
            return pollCreateManager.hasTime ? 4 : 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.pollOption,
                                                            for: indexPath) as? CreatePollOptionCell {
                    cell.delegate = self
                    cell.indexPath = indexPath
                    cell.editable = pollCreateManager.options[indexPath.row].editable
                    cell.initialText = pollCreateManager.options[indexPath.row].title
                    cell.showAddBtn = indexPath.row == pollCreateManager.options.count - 1
                    cell.showDeleteBtn = pollCreateManager.options.count > 2
                    return cell
                } else {
                    return UITableViewCell()
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.pollSetting,
                                                         for: indexPath)
                switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = "Are Voters anonymous?"
                        cell.accessoryView = anonymousSwitch
                    case 1:
                        cell.textLabel?.text = "Has Time Limit?"
                        cell.accessoryView = hasTimeSwitch
                    case 2:
                        cell.textLabel?.text = "Start Time"
                        cell.accessoryView = startTimePicker
                    case 3:
                        cell.textLabel?.text = "End Time"
                        cell.accessoryView = endTimePicker
                    default:
                        break
                }
                cell.isSkeletonable = true
                return cell
            default:
                return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
            case 0:
                return sectionTitleLabel("Options")
            case 1:
                return sectionTitleLabel("Poll Settings")
            default:
                return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
}

// MARK: - UITableViewDelegate
extension CreatePollViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: indexPath.section > 0)
    }
    
}

// MARK: - CreatePollOptionCellDelegate
extension CreatePollViewController: CreatePollOptionCellDelegate {
    func didChangePollText(_ cell: CreatePollOptionCell, sender: UITextField, text: String, for indexPath: IndexPath?) {
        if let indexPath = indexPath {
            pollCreateManager.options[indexPath.row].title = text
        }
    }
    
    func didDeleteOptionCell(_ cell: CreatePollOptionCell, at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            pollCreateManager.options.remove(at: indexPath.row)
            optionsTableView.reloadData()
        }
    }
    
    func didAddNewOptionCell(_ sender: CreatePollOptionCell) {
        pollCreateManager.options
            .append(PollOptionDto("Option \(pollCreateManager.optionCount)"))
        optionsTableView.reloadData()
        optionsTableView.scrollToRow(at: IndexPath(row: pollCreateManager.options.count-1,
                                                   section: 0),
                                     at: .bottom, animated: true)
    }
    
}

// MARK: - PollCreateManagerDelegate
extension CreatePollViewController: PollCreateManagerDelegate {
    
    func didTogglePollHasTime(_ viewModel: PollCreateManager, value: Bool) {
        UIView.transition(with: optionsTableView,
                          duration: 0.5,
                          options: .curveEaseInOut,
                          animations: { self.optionsTableView.reloadData() })
    }
    
    func startTimeDidChange(_ viewModel: PollCreateManager, cause: TimeCause, to date: Date) {
        if cause == .end {
            let animation = CABasicAnimation(keyPath: "backgroundColor")
            animation.fromValue = Constants.Colors.darkBlue!.cgColor
            animation.toValue = UIColor.red.cgColor
            animation.duration = 1
            startTimePicker.layer.add(animation, forKey: "backgroundColor")
        }
        startTimePicker.setDate(date, animated: true)
    }
    
    func endTimeDidChange(_ viewModel: PollCreateManager, cause: TimeCause, to date: Date) {
        endTimePicker.setDate(date, animated: true)
        if cause == .start {
            let animation = CABasicAnimation(keyPath: "backgroundColor")
            animation.fromValue = Constants.Colors.darkBlue!.cgColor
            animation.toValue = UIColor.red.cgColor
            animation.duration = 1
            endTimePicker.layer.add(animation, forKey: "backgroundColor")
        }
    }
    
    func updateEditMode(_ poll: Poll) {
        // update the ViewModel
        pollCreateManager.startTime = poll.startTime
        pollCreateManager.endTime = poll.endTime
        pollCreateManager.options = poll.options!.map {
            PollOptionDto($0.title, with: $0.id, canEdit: false) }
        pollCreateManager.hasTime = poll.hasTimeLimit
        pollCreateManager.isVoterAnonymous = poll.isAnonymous
        
        // disable EDIT features
        startTimePicker.isEnabled = false
        pollTitleTF.text = poll.title
        pollCreateBtn.setTitle("Edit Poll", for: .normal)
        hasTimeSwitch.isOn = poll.hasTimeLimit
        anonymousSwitch.isOn = poll.isAnonymous
        
        if poll.hasTimeLimit {
            endTimePicker.date = poll.endTime! 
            endTimePicker.minimumDate = max(.init(), poll.endTime!)
        } else {
            endTimePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: .init())
            endTimePicker.date = .init()
        }
        
    }
}

// MARK: - PollManagerDelegate
extension CreatePollViewController: PollManagerDelegate {
    func finishedFetchingPolls(_ success: Bool) {}
    
    func finishedFetchingPoll(_ poll: Poll?, or error: IPollError?) {
        view.stopSkeletonAnimation()
        view.hideSkeleton()
        if let error = error {
            showErrorAlert(title: "Action Failed",
                           with: "An error occured fetching poll for edit\n\(error)",
                           addBackButton: true,
                           addOkButton: false)
        }
        if let poll = poll {
            updateEditMode(poll)
            optionsTableView.reloadData()
        }
    }
}
