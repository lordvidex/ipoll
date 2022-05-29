//
//  OnboardViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 15.05.2022.
//

import UIKit
import SnapKit
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseGoogleAuthUI

class OnboardViewController: UIViewController {
    // MARK: - private variables
    weak var authUI: FUIAuth?
    
    // MARK: - UI
    lazy var welcomeLabel: IPLabel = {
        let label = IPLabel("Welcome to IPoll.. (Quick Auth)")
        label.font = Constants.appFont?.withSize(24)
        return label
    }()
    
    lazy var instructionLabel: IPLabel = {
        let label = IPLabel("Please enter your only your name for non-anonymous posts")
        return label
    }()
    
    lazy var skipBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Skip", for: .normal)
        btn.addTarget(self, action: #selector(setUserIdAndName), for: .touchUpInside)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    lazy var fullAuthBtn: IPButton = {
        let btn = IPButton(text: "Full Sign In", cornerRadius: 10)
        btn.addTarget(self, action: #selector(showAuthUI), for: .touchUpInside)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var goBtn: IPButton = {
        let btn = IPButton()
        btn.backgroundColor = Constants.Colors.lightBlue
        btn.tintColor = Constants.Colors.darkBlue
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
        
        setupFirebaseAuthUI()
        setupViews()
    }
    
    private func setupFirebaseAuthUI() {
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        var githubProvider = OAuthProvider(providerID: "github.com")
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth.init(authUI: authUI!),
            FUIOAuth.githubAuthProvider(withAuthUI: authUI!)
        ]
        
        authUI?.providers = providers
    }
    
    @objc private func showAuthUI() {
        guard let viewController = authUI?.authViewController() else { return }
        present(viewController, animated: true)
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
        
        fullAuthBtn.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(25)
            make.centerX.equalTo(scrollView)
        }
        
        skipBtn.snp.makeConstraints { make in
            make.top.equalTo(fullAuthBtn.snp.bottom).offset(25)
            make.centerX.equalTo(scrollView)
        }
        
        
        
    }
}

extension OnboardViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print(authDataResult?.user)
        print(authDataResult?.additionalUserInfo)
        print(error)
    }
}
