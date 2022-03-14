//
//  JoinPollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 14.03.2022.
//

import UIKit
import SnapKit

class JoinPollViewController: UIViewController {
    
    private var joinPollLabel: UILabel = {
        let label = IPLabel("Join a poll", font: Constants.appFont?.withSize(24))
        return label
    }()
    
    
    private var pollIdTF: UITextField = {
        let tf = IPTextField()
        return tf
    }()
    
    
    var pollIdLabel: UILabel = {
        let label = IPLabel("Poll #ID")
        label.font = Constants.appFont?.withSize(14)
        return label
    }()
    
    
    private var joinBtn: IPButton = {
        let btn = IPButton(text: "Join")
        btn.addTarget(self, action: #selector(onJoinBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    
    private var scanBtn: UIButton = {
        
        let btn = UIButton()
        btn.setTitle("Scan QR", for: .normal)
        btn.layer.cornerRadius = 6
        btn.backgroundColor = .clear
        btn.titleLabel?.font = Constants.appFont?.withSize(18)
        btn.setTitleColor(UIColor(named: Constants.Colors.darkBlue), for: .normal)
        
        // TODO: add btn target to open QR Code Scanner
        
        return btn
    }()
    
    
    private var fab: IPButton = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: Constants.Colors.bgBlue)
        view.addSubview(joinPollLabel)
        view.addSubview(pollIdLabel)
        view.addSubview(pollIdTF)
        view.addSubview(joinBtn)
        view.addSubview(scanBtn)
        view.addSubview(fab)
        
        joinPollLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(100)
            make.left.right.equalTo(self.view).inset(10)
        }
        
        pollIdLabel.snp.makeConstraints { make in
            make.left.right.equalTo(joinPollLabel)
            make.top.equalTo(joinPollLabel.snp.bottom).offset(20)
            make.bottom.equalTo(pollIdTF.snp.top)
        }
        
        joinBtn.snp.makeConstraints { make in
            make.top.equalTo(pollIdTF.snp.bottom).offset(14)
            make.left.right.equalTo(joinPollLabel)
        }
        
        pollIdTF.snp.makeConstraints { make in
            make.left.right.equalTo(pollIdLabel)
        }
        
        scanBtn.snp.makeConstraints { make in
            make.left.right.equalTo(joinBtn)
            make.height.equalTo(99)
            make.top.equalTo(joinBtn.snp.bottom).offset(28)
        }
        fab.snp.makeConstraints { make in
            make.right.bottom.equalTo(self.view).inset(30)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // add dashed border to scanBtn
        addDottedDashes(to: scanBtn)
        
    }
    
    private func addDottedDashes(to view: UIView) {
        let border = CAShapeLayer()
        border.strokeColor = UIColor(named: Constants.Colors.darkBlue)?.cgColor
        border.lineDashPattern = [4,2]
        border.fillColor = nil
        border.frame = view.bounds
        border.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize.zero).cgPath
        
        // add to sublayer
        view.layer.addSublayer(border)
    }
    
    @objc func onJoinBtnClicked() {
        //TODO: link join poll function
        print("Clicked")
    }
    
    @objc func onTapFab(_ sender: UIButton) {
        let viewControllers = navigationController?.viewControllers
        if var viewControllers = viewControllers {
            viewControllers.removeLast()
            viewControllers.append(CreatePollViewController())
            navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    
}
