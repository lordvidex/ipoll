//
//  CreatePollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class CreatePollViewController: UIViewController {

    var options = ["Option 1", "Option 2"]

    private var _optionCount = 2
    private var optionCount: Int {
        _optionCount += 1
        return _optionCount

    }
    weak var pollManager: PollManager! = .shared

    private var pollTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Poll Title"
        label.textColor = Constants.Colors.darkBlue
        label.font = Constants.appFont?.withSize(18)
        return label
    }()

    private var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Poll"
        label.font = Constants.appFont?.withSize(24)
        label.textColor = Constants.Colors.darkBlue
        return label
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

    private var optionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Options"
        label.font = Constants.appFont?.withSize(14)
        label.textColor = Constants.Colors.darkBlue
        return label
    }()

    private var loadingIndicator: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.hidesWhenStopped = true
        return loading
    }()

    private lazy var optionsTableView: UITableView = {
        let table = UITableView()
        table.register(UINib(nibName: Constants.CellIdentifiers.pollOption,
                             bundle: nil),
                       forCellReuseIdentifier: Constants.CellIdentifiers.pollOption)
        table.separatorStyle = .none
        table.allowsSelection = false
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        optionsTableView.dataSource = self
        loadingIndicator.stopAnimating()

        view.backgroundColor = .white

        view.addSubview(headerLabel)
        view.addSubview(pollTitleLabel)
        view.addSubview(pollTitleTF)
        view.addSubview(optionsLabel)
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
        optionsLabel.snp.makeConstraints { make in
            make.left.right.equalTo(pollTitleTF)
            make.top.equalTo(pollTitleTF.snp.bottom).offset(56)
        }
        pollCreateBtn.snp.makeConstraints { make in
            make.left.right.equalTo(pollTitleTF)
            make.bottom.equalTo(view).offset(-26)
        }
        optionsTableView.snp.makeConstraints { make in
            make.left.right.equalTo(safeArea).inset(5)
            make.top.equalTo(optionsLabel.snp.bottom).offset(10)
            make.bottom.equalTo(pollCreateBtn.snp.top).offset(-5)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }

    @objc func createPoll() {
        loadingIndicator.startAnimating()
        pollManager.createPoll(
            title: (pollTitleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,
            options: options) { [weak self] result in
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

}

// MARK: - UITableViewDataSource
extension CreatePollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.pollOption,
                                                    for: indexPath) as? CreatePollOptionCell {
            cell.delegate = self
            cell.indexPath = indexPath
            cell.initialText = options[indexPath.row]
            cell.showAddBtn = indexPath.row == options.count - 1
            cell.showDeleteBtn = options.count > 2
            return cell
        } else {
            return UITableViewCell()
        }
    }

}

// MARK: - CreatePollOptionCellDelegate
extension CreatePollViewController: CreatePollOptionCellDelegate {
    func didChangePollText(_ cell: CreatePollOptionCell, sender: UITextField, text: String, for indexPath: IndexPath?) {
        if let indexPath = indexPath {
            options[indexPath.row] = text
        }
    }

    func didDeleteOptionCell(_ cell: CreatePollOptionCell, at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            options.remove(at: indexPath.row)
            optionsTableView.reloadData()
        }
    }

    func didAddNewOptionCell(_ sender: CreatePollOptionCell) {
        options.append("Option \(optionCount)")
        optionsTableView.reloadData()
        optionsTableView.scrollToRow(at: IndexPath(row: options.count-1, section: 0), at: .bottom, animated: true)
    }

}
