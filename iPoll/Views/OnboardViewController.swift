//
//  OnboardViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 15.05.2022.
//

import UIKit
import SnapKit

class OnboardViewController: UIViewController {
    
    lazy var welcomeLabel: IPLabel = {
        let label = IPLabel("Welcome to IPoll..")
        label.font = Constants.appFont?.withSize(24)
        return label
    }()
    lazy var instructionLabel: IPLabel = {
        let label = IPLabel("Please enter your name for non-anonymous posts")
        return label
    }()
    
    lazy var skipBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Skip", for: .normal)
        btn.addTarget(self, action: #selector(setUserIdAndName), for: .touchUpInside)
//        btn.configuration = .tinted()
        return btn
    }()
    
    lazy var goBtn: IPButton = {
        let btn = IPButton()
//        btn.configuration = UIButton.Configuration.filled()
        btn.tintColor = Constants.Colors.lightBlue
        btn.addTarget(self, action: #selector(setUserIdAndName), for: .touchUpInside)
        btn.setImage(UIImage.arrowRight, for: .normal)
        return btn
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollv = UIScrollView()
        return scrollv
    }()
    
    lazy var textField: IPTextField = {
        let tf = IPTextField()
        tf.rightView = goBtn
        tf.rightViewMode = .whileEditing
        return tf
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc func setUserIdAndName() {
        NetworkService.shared.setUser(name: textField.text) { [weak self] result in
            switch result {
            case .success:
                if let mainUrl = URL(string: "ipoll://main") {
                    Router.to(mainUrl)
                } else {
                    self?.showErrorAlert(title: "malformed url", addBackButton: false)
                }
            case .failure(let err):
                self?.showErrorAlert(title: err.message, addBackButton: false)
            }
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(welcomeLabel)
        scrollView.addSubview(instructionLabel)
        scrollView.addSubview(textField)
        scrollView.addSubview(skipBtn)
        
        // scroll view constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView).inset(25)
            make.top.equalTo(scrollView).offset(50)
        }
        instructionLabel.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(30)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(10)
            make.left.right.equalTo(view).inset(25)
        }
//        goBtn.snp.makeConstraints { make in
//            make.width.height.equalTo(textField.snp.height)
//        }
        skipBtn.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(25)
            make.centerX.equalTo(scrollView)
        }
        
    }
}
