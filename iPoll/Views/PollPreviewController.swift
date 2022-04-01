//
//  PollPreviewController.swift
//  iPoll
//
//  Created by Evans Owamoyo on 21.03.2022.
//

import UIKit
import SnapKit

class PollPreviewController: UIViewController {
    private var pollTitle: String
    private var pollId: String

    init(pollId: String, pollTitle: String) {
        self.pollId = pollId
        self.pollTitle = pollTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("No coder for PollPreviewController")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        navigationItem.title = pollTitle

        let qrCode = UIImageView(image: QRGenerator.generatePollQR(poll: pollId))
        let titleLabel = IPLabel("Poll: \(pollTitle)", textColor: .black, font: Constants.appFont?.withSize(18))
        let titleView = UIView()
        titleView.backgroundColor = .lightGray

        self.view.addSubview(qrCode)
        titleView.addSubview(titleLabel)
        self.view.addSubview(titleView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(titleView)
        }
        titleView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.left.right.equalTo(self.view)
        }

        qrCode.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(self.view)
            make.width.height.equalTo(self.view.snp.width)
        }
    }
}
