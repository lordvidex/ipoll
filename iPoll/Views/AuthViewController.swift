//
//  AuthViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 15.05.2022.
//

import UIKit
import SnapKit
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI

class AuthViewController: UIViewController {
    // MARK: - private variables
    weak var authUI: FUIAuth?
    
    // MARK: - Constructors
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(id: String?, name: String?) {
        self.init()
        if let id = id, let name = name {
            setUserIdAndName(id: id, name: name)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    lazy var welcomeLabel: IPLabel = {
        let label = IPLabel("Welcome to IPoll.. You can authorize quickly or authorize using standard authentication methods: ")
        label.font = Constants.appFont?.withSize(24)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var quickAuthLabel: IPLabel = {
        let label = IPLabel("Quick Auth: (only name)")
        label.textAlignment = .left
        label.font = Constants.appFont?.withSize(18)
        scrollView.addSubview(label)
        return label
    }()
    
    lazy var standardAuthLabel: IPLabel = {
        let label = IPLabel("Standard Auth: ")
        label.textAlignment = .left
        label.font = Constants.appFont?.withSize(18)
        scrollView.addSubview(label)
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
    
    var spinner: UIActivityIndicatorView?
    
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
        if let authUI = authUI {
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://ipoll.page.link")
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

            let providers: [FUIAuthProvider] = [
                FUIGoogleAuth.init(authUI: authUI),
                FUIOAuth.githubAuthProvider(withAuthUI: authUI),
                FUIEmailAuth.init(authAuthUI: authUI,
                                  signInMethod: "password",
                                  forceSameDevice: false,
                                  allowNewEmailAccounts: true,
                                  requireDisplayName: true,
                                  actionCodeSetting: actionCodeSettings)
                
            ]
            authUI.providers = providers
        }
        
    }
    
    private func showLoadingSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        view.addSubview(spinner!)
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        spinner!.snp.makeConstraints({ make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        })
        spinner?.startAnimating()
    }
    
    private func removeLoadingSpinner() {
        
        if let spinner = spinner {
            spinner.removeFromSuperview()
            self.spinner = nil
        }
        view.backgroundColor = nil
    }
    
    @objc private func showAuthUI() {
        guard let viewController = authUI?.authViewController() else { return }
        present(viewController, animated: true)
    }
    
    @objc func setUserIdAndName(id: String? = nil, name: String? = nil) {
        showLoadingSpinner()
        NetworkService.shared.setUser(id: id, name: name ?? textField.text) { [weak self] result in
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
            DispatchQueue.main.async {
                self?.removeLoadingSpinner()
            }
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(welcomeLabel)
        scrollView.addSubview(textField)
        scrollView.addSubview(skipBtn)
        
        // scroll view constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.top.equalTo(scrollView).offset(50)
        }
        
        quickAuthLabel.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(20)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(quickAuthLabel.snp.bottom).offset(10)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(25)
        }
        
        standardAuthLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(25)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(25)
        }
        
        fullAuthBtn.snp.makeConstraints { make in
            make.top.equalTo(standardAuthLabel.snp.bottom).offset(10)
            make.centerX.equalTo(scrollView)
            make.width.equalTo(scrollView).inset(40)
        }
        
        skipBtn.snp.makeConstraints { make in
            make.top.equalTo(fullAuthBtn.snp.bottom).offset(25)
            make.centerX.equalTo(scrollView)
        }
    }
}

extension AuthViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let result = authDataResult {
            let user = result.user
            setUserIdAndName(id: user.uid, name: user.displayName ?? user.email)
            return
        }
        if let error = error {
            print(error)
        }
    }
}
