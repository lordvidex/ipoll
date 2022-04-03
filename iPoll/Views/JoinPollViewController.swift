//
//  JoinPollViewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 14.03.2022.
//

import UIKit
import SnapKit
import Toast_Swift

class JoinPollViewController: UIViewController {

    private var joinPollLabel: UILabel = {
        let label = IPLabel("Join a poll", font: Constants.appFont?.withSize(24))
        return label
    }()

    var pollIdTF: UITextField = {
        let tf = IPTextField()
        return tf
    }()

    private var pollIdLabel: UILabel = {
        let label = IPLabel("Poll #ID")
        label.font = Constants.appFont?.withSize(14)
        return label
    }()

    private lazy var joinBtn: IPButton = {
        let btn = IPButton(text: "Join")
        btn.addTarget(self, action: #selector(onJoinBtnClicked), for: .touchUpInside)
        return btn
    }()

    private lazy var scanBtn: UIButton = {

        let btn = UIButton()
        btn.setTitle("Scan QR", for: .normal)
        btn.layer.cornerRadius = 6
        btn.backgroundColor = .clear
        btn.titleLabel?.font = Constants.appFont?.withSize(18)
        btn.setTitleColor(Constants.Colors.darkBlue, for: .normal)
        btn.addTarget(self, action: #selector(openScanner), for: .touchUpInside)

        return btn
    }()

    private lazy var fab: IPButton = {
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
        view.backgroundColor = Constants.Colors.bgBlue
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
        border.strokeColor = Constants.Colors.darkBlue?.cgColor
        border.lineDashPattern = [4, 2]
        border.fillColor = nil
        border.frame = view.bounds
        border.path = UIBezierPath(roundedRect: view.bounds,
                                   byRoundingCorners: .allCorners,
                                   cornerRadii: CGSize.zero).cgPath

        // add to sublayer
        view.layer.addSublayer(border)
    }

    @objc func onJoinBtnClicked() {
        if let id = pollIdTF.text {
            let voteVC = VoteViewController()
            voteVC.pollId = id.trimmingCharacters(in: .whitespacesAndNewlines)
            print(voteVC.pollId!)
            navigationController?.pushViewController(voteVC, animated: true)
        }
    }

    @objc func onTapFab(_ sender: UIButton) {
        let viewControllers = navigationController?.viewControllers
        if var viewControllers = viewControllers {
            viewControllers.removeLast()
            viewControllers.append(CreatePollViewController())
            navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }

    @objc func openScanner() {
        let qrScannerVC = QRScannerViewController { error in
            self.view.makeToast(error)
        }
        navigationController?.pushViewController(qrScannerVC, animated: true)
    }

}
