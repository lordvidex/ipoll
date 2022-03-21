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
        get {
            _optionCount += 1
            return _optionCount
        }
    }
    weak var pollManager: PollManager! = .shared
    
    @UsesAutoLayout
    private var pollTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Poll Title"
        label.textColor = Constants.Colors.darkBlue
        label.font = Constants.appFont?.withSize(18)
        return label
    }()
    
    @UsesAutoLayout
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Poll"
        label.font = Constants.appFont?.withSize(24)
        label.textColor = Constants.Colors.darkBlue
        return label
    }()
    
    @UsesAutoLayout
    var pollTitleTF: UITextField = {
        let tf = IPTextField()
        tf.text = "Hello World!"
        return tf
    }()
    
    @UsesAutoLayout
    private var pollCreateBtn: UIButton = {
        let btn = IPButton(text: "Create poll", textColor: .white)
        btn.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        return btn
    }()
    
    @UsesAutoLayout
    private var optionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Options"
        label.font = Constants.appFont?.withSize(14)
        label.textColor = Constants.Colors.darkBlue
        return label
    }()
    
    @UsesAutoLayout
    private var loadingIndicator: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.hidesWhenStopped = true
        return loading
    }()
    
    @UsesAutoLayout
    private var optionsTableView: UITableView = {
        let table = UITableView()
        table.register(UINib(nibName: Constants.CellIdentifiers.pollOption, bundle: nil), forCellReuseIdentifier: Constants.CellIdentifiers.pollOption)
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
        
        NSLayoutConstraint.activate([
            headerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            headerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            headerLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            
            pollTitleTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pollTitleTF.leftAnchor.constraint(equalTo: headerLabel.leftAnchor, constant: 20),
            pollTitleTF.rightAnchor.constraint(equalTo: headerLabel.rightAnchor, constant: -20),
            pollTitleTF.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 40),
            
            pollTitleLabel.leftAnchor.constraint(equalTo: pollTitleTF.leftAnchor),
            pollTitleLabel.bottomAnchor.constraint(equalTo: pollTitleTF.topAnchor, constant: -5),
            
            optionsLabel.leftAnchor.constraint(equalTo: pollTitleTF.leftAnchor),
            optionsLabel.rightAnchor.constraint(equalTo: pollTitleTF.rightAnchor),
            optionsLabel.topAnchor.constraint(equalTo: pollTitleTF.bottomAnchor, constant: 56),
            
            pollCreateBtn.leftAnchor.constraint(equalTo: pollTitleTF.leftAnchor),
            pollCreateBtn.rightAnchor.constraint(equalTo: pollTitleTF.rightAnchor),
            
            
            pollCreateBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -26),
            
            optionsTableView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 5),
            optionsTableView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -5),
            optionsTableView.topAnchor.constraint(equalTo: optionsLabel.bottomAnchor, constant: 10),
            optionsTableView.bottomAnchor.constraint(equalTo: pollCreateBtn.topAnchor, constant: -5),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func createPoll() {
        loadingIndicator.startAnimating()
        pollManager.createPoll(title: (pollTitleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines))!, options: options) { [weak self] result in
            switch result {
                case .success(_):
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.pollOption, for: indexPath) as? CreatePollOptionCell {
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
        optionsTableView.scrollToRow(at: IndexPath(row: options.count-1 , section: 0), at: .bottom, animated: true)
    }

    
}
