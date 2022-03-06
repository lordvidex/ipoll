//
//  CreatePollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class CreatePollViewController: UIViewController {
    
    @UsesAutoLayout
    var pollTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Poll Title"
        label.textColor = UIColor(hexString: "#525F7A")
        label.font = UIFont(name: "Futura PT", size: 14)
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
        let btn = Button()
        btn.setTitle("Create poll", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        return btn
    }()
    
    var cview: UIView = {
        let v = UIView()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addSubview(pollTitleLabel)
        view.addSubview(pollTitleTF)
        view.addSubview(pollCreateBtn)
        
        NSLayoutConstraint.activate([
            pollTitleTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pollTitleTF.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            pollTitleTF.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            pollTitleTF.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pollTitleLabel.leftAnchor.constraint(equalTo: pollTitleTF.leftAnchor),
            pollTitleLabel.bottomAnchor.constraint(equalTo: pollTitleTF.topAnchor, constant: -5),
            pollCreateBtn.leftAnchor.constraint(equalTo: pollTitleTF.leftAnchor),
            pollCreateBtn.rightAnchor.constraint(equalTo: pollTitleTF.rightAnchor),
            pollCreateBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -26)
        ])
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func createPoll() {
//        navigationController?.pushViewController(PollListController(), animated: true)
    }

}
