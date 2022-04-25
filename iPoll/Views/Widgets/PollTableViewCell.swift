//
//  PollTableViewCell.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit

class PollTableViewCell: UITableViewCell {
    
    var poll: Poll? {
        didSet {
            if let poll = poll {
                pollLabel.text = poll.title
                if let color = poll.color {
                    mainView.backgroundColor = color.lighter()
                    mainView.layer.borderColor = color.darker(componentDelta: 0.2).cgColor
                } else {
                    mainView.backgroundColor = UIColor(hexString: "#CCDBFD")
                    mainView.layer.borderColor = UIColor(hexString: "#ABC4FF").cgColor
                }
                updateTimeLabel()
            }
        }
    }
    
    weak var periodicManager: PeriodicManager? = .shared
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor(hexString: "#CCDBFD")
        view.layer.borderColor = UIColor(hexString: "#ABC4FF").cgColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var pollLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#052161")
        label.font = Constants.appFont
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var arrow: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let view = UIImageView(image: image)
        view.tintColor = UIColor(hexString: "#052161")
        return view
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = Constants.appFont
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // attach to periodicManager
        periodicManager?.addListener(self)
        
        // setup views
        contentView.backgroundColor = Constants.Colors.bgBlue
        mainView.addSubview(pollLabel)
        mainView.addSubview(arrow)
        mainView.addSubview(timerLabel)
        contentView.addSubview(mainView)
        
        mainView.snp.makeConstraints { make in
            make.left.right.equalTo(contentView).inset(2)
            make.top.bottom.equalTo(contentView).inset(5)
            make.height.greaterThanOrEqualTo(80)
        }
        arrow.snp.makeConstraints { make in
            make.centerY.equalTo(mainView)
            make.right.equalTo(mainView).offset(-14)
            make.width.greaterThanOrEqualTo(12)
        }
        timerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(mainView)
            make.right.equalTo(arrow.snp.left).offset(-5)
            make.width.equalTo(50).priority(.medium)
        }
        pollLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(mainView).inset(13)
            make.right.lessThanOrEqualTo(timerLabel.snp.left).offset(-12)
            make.left.equalTo(mainView).offset(10)
        }
        
    }
    
    func updateTimeLabel() {
        if let poll = poll {
            var string = ""
            var color: UIColor = Constants.Colors.darkBlue!
            
            if let endTime = poll.endTime, poll.hasTimeLimit {
                let interval = Int64(endTime.timeIntervalSinceNow.rounded(.up))
                if interval < 0 {
                    string = "Expired"
                } else if interval > 86400 { // up to a day
                    let days = Int64(interval / 86400)
                    string = "~\(days) days"
                } else if interval <= 60 { // less than a minute
                    string = "<1 min"
                    color = .red
                } else {
                    let mins = (interval / 60) % 60
                    let hrs = (interval / 3600)
                    string = "\(hrs)h:\(mins)m"
                }
            } else {
                string = "\u{221E}"
            }
            self.timerLabel.text = string
            self.timerLabel.textColor = color
        }
    }
    
    deinit {
        periodicManager?.removeListener(self)
    }
}

extension PollTableViewCell: PeriodicManagerDelegate {
    func didCallUpdate(_ manager: PeriodicManager, with timer: Timer, period: TimeInterval) {
        DispatchQueue.main.async {
            self.updateTimeLabel()
        }
    }
}
