//
//  CreatePollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class CreatePollViewController: UIViewController {
    
    weak var pollManager: PollManager! = .shared
    weak var pollCreateManager: PollCreateManager! = .shared
    
    private lazy var pollTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Poll Title"
        label.textColor = Constants.Colors.darkBlue
        label.font = Constants.appFont?.withSize(18)
        return label
    }()
    
    private lazy var startTimePicker: UIDatePicker = {
        let pickerView = UIDatePicker(frame: .zero)
        pickerView.datePickerMode = .dateAndTime
        pickerView.addTarget(self, action: #selector(onStartTimeChanged), for: .valueChanged)
        return pickerView
    }()
    
    private lazy var endTimePicker: UIDatePicker = {
        let pickerView = UIDatePicker(frame: .zero)
        pickerView.datePickerMode = .dateAndTime
        pickerView.addTarget(self, action: #selector(onEndTimeChanged), for: .valueChanged)
        return pickerView
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Poll"
        label.font = Constants.appFont?.withSize(24)
        label.textColor = Constants.Colors.darkBlue
        return label
    }()
    
    private lazy var hasTimeSwitch: UISwitch  = {
        let swtch = UISwitch(frame: .zero)
        swtch.setOn(pollCreateManager.hasTime, animated: false)
        swtch.addTarget(self, action: #selector(onHasTimeSwitchChanged), for: .valueChanged)
        return swtch
    }()
    
    lazy var pollTitleTF: UITextField = {
        let tf = IPTextField()
        tf.text = "Hello World!"
        return tf
    }()
    
    private lazy var pollCreateBtn: UIButton = {
        let btn = IPButton(text: "Create poll", textColor: .white)
        btn.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        return btn
    }()
    
    private func sectionTitleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = Constants.appFont?.withSize(14)
        label.textColor = Constants.Colors.darkBlue
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
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        pollCreateManager.delegate = self
        
        pollCreateManager.startTime = startTimePicker.date
        pollCreateManager.endTime = endTimePicker.date
        
        loadingIndicator.stopAnimating()
        
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
        loadingIndicator.startAnimating()
        pollManager.createPoll(
            title: pollTitleTF.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            options: pollCreateManager.options
        ) { [weak self] result in
            switch result {
                case .success:
                    DispatchQueue.main.async {
                        let pollVC = PollViewController()
                        pollVC.activeSegmentedControlIndex = 2
                        self?.navigationController?.viewControllers = [pollVC]
                    }
                case .failure(let err):
                    print(err)
                    
            }
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
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
    
}

// MARK: - UITableViewDataSource
extension CreatePollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pollCreateManager.options.count
        } else if section == 1 {
            return pollCreateManager.hasTime ? 3 : 1
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
                    cell.initialText = pollCreateManager.options[indexPath.row]
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
                        cell.textLabel?.text = "Has Time Limit?"
                        cell.accessoryView = hasTimeSwitch
                    case 1:
                        cell.textLabel?.text = "Start Time"
                        cell.accessoryView = startTimePicker
                    case 2:
                        cell.textLabel?.text = "End Time"
                        cell.accessoryView = endTimePicker
                    default:
                        break
                }
                
                return cell
            default:
                return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Options"
            case 1:
                return "Poll Settings"
            default:
                return nil
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
            pollCreateManager.options[indexPath.row] = text
        }
    }
    
    func didDeleteOptionCell(_ cell: CreatePollOptionCell, at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            pollCreateManager.options.remove(at: indexPath.row)
            optionsTableView.reloadData()
        }
    }
    
    func didAddNewOptionCell(_ sender: CreatePollOptionCell) {
        pollCreateManager.options.append("Option \(pollCreateManager.optionCount)")
        optionsTableView.reloadData()
        optionsTableView.scrollToRow(at: IndexPath(row: pollCreateManager.options.count-1,
                                                   section: 0),
                                     at: .bottom, animated: true)
    }
    
}

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
}
