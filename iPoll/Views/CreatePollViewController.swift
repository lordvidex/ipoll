//
//  CreatePollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class CreatePollViewController: UIViewController {
    
    var options = ["Option 1", "Option 2"]
    
    @UsesAutoLayout
    var pollTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Poll Title"
        label.textColor = UIColor(named: Constants.Colors.darkBlue)
        label.font = Constants.appFont?.withSize(18)
        return label
    }()
    
    @UsesAutoLayout
    var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Poll"
        label.font = Constants.appFont?.withSize(24)
        label.textColor = UIColor(named: Constants.Colors.darkBlue)
        return label
    }()
    
    @UsesAutoLayout
    var pollTitleTF: UITextField = {
        let tf = TextField()
        tf.text = "Hello World!"
        return tf
    }()
    
    @UsesAutoLayout
    var pollCreateBtn: UIButton = {
        let btn = Button(text: "Create poll", textColor: .white)
        btn.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        return btn
    }()
    
    @UsesAutoLayout
    var optionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Options"
        label.font = Constants.appFont?.withSize(14)
        label.textColor = UIColor(named: Constants.Colors.darkBlue)
        return label
    }()
    
    @UsesAutoLayout
    var optionsTableView: UITableView = {
        let table = UITableView()
        table.register(CreatePollOptionCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.pollOption)
        table.separatorStyle = .none
        table.allowsSelection = false
        table.backgroundColor = .black
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        view.backgroundColor = .white
        
        view.addSubview(headerLabel)
        view.addSubview(pollTitleLabel)
        view.addSubview(pollTitleTF)
        view.addSubview(optionsLabel)
        view.addSubview(optionsTableView)
        view.addSubview(pollCreateBtn)
        
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
            
            optionsTableView.leftAnchor.constraint(equalTo: optionsLabel.leftAnchor),
            optionsTableView.rightAnchor.constraint(equalTo: optionsLabel.rightAnchor),
            optionsTableView.topAnchor.constraint(equalTo: optionsLabel.bottomAnchor, constant: 10),
            optionsTableView.bottomAnchor.constraint(equalTo: pollCreateBtn.topAnchor, constant: -5)
            
        ])
    }
    
    @objc func createPoll() {
        //        navigationController?.pushViewController(PollListController(), animated: true)
    }
    
}

// MARK: - UITableViewDelegate
extension CreatePollViewController: UITableViewDelegate {
    
}


// MARK: - UITableViewDataSource
extension CreatePollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.pollOption, for: indexPath) as? CreatePollOptionCell {
            cell.initialText = options[indexPath.row]
            cell.showOptionBtn = indexPath.row == options.count - 1
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
}

// MARK: - CreatePollOptionCellDelegate
extension CreatePollViewController: CreatePollOptionCellDelegate {
    func didAddNewOptionCell(_ sender: CreatePollOptionCell) {
        options.append("Option \(options.count)")
        optionsTableView.reloadData()
    }
    
    func didChangePollText(_ sender: CreatePollOptionCell, text: String, for indexPath: IndexPath?) {
        if let indexPath = indexPath {
            options[indexPath.row] = text
        }
    }
    
}
