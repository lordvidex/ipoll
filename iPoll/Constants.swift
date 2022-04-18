//
//  Constants.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit

struct Constants {

    // MARK: colors in assets
    struct Colors {
        static let darkBlue = UIColor(named: "DarkBlue")
        static let lightBlue = UIColor(named: "LightBlue")
        static let bgBlue = UIColor(named: "BgBlue")
        static let appBlack = UIColor(named: "AppBlack")
        static let borderBlue = UIColor(named: "BorderBlue")
    }

    // MARK: cell identifiers
    struct CellIdentifiers {
        static let pollOption = "CreatePollOptionCell"
        static let voteOption = "VoteOptionCell"
        static let voteCustomSettings = "VoteCustomSettings"
        static let pollSetting = "CreatePollSettingCell"
    }

    static var appFont = UIFont(name: "Futura-Medium", size: 16)
}
