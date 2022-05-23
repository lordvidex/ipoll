//
//  Router.swift
//  iPoll
//
//  Created by Evans Owamoyo on 21.03.2022.
//

import Foundation
import UIKit

typealias FailureCallBack = (String) -> Void

enum Host: String {
    case join
    case poll
    case create
    case main
}

class Router {
    // MARK: singleton
    static let shared = Router()
    
    // MARK: variables
    private init () {}
    
    private weak var window: UIWindow?
    
    static var navigator: UINavigationController? {
        return Router.shared.window?.rootViewController as? UINavigationController
    }
    
    // MARK: - functions
    static func configure(with window: UIWindow) {
        Router.shared.window = window
        let navController: UINavigationController
        
        if NetworkService.userId == nil {
            // first time user - onboard and save the user
            navController = UINavigationController(rootViewController: OnboardViewController())
        } else {
            // already logged in user
            navController = UINavigationController(rootViewController: PollViewController())
        }
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
    
    // uses the shared window instance to navigate to pages
    static func to(_ url: URL, failedWith reason: FailureCallBack? = nil) {
        if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
           let hostString = components.host,
           let host = Host(rawValue: hostString),
           let scheme = components.scheme {
            
            // check if the scheme is valid
            if scheme.lowercased() != "ipoll" {
                reason?("Invalid QRCode / Link")
                return
            }
            // parse the hosts
            //
            switch host {
                
            case .join:
                // navigate to the join poll screen
                let joinPollViewContoller = JoinPollViewController()
                if let params = components.queryItems {
                    let id = params.first { $0.name == "id" }
                    if let id = id {
                        joinPollViewContoller.pollIdTF.text = id.value
                    }
                    navigator?.pushViewController(joinPollViewContoller, animated: true)
                }
            case .poll:
                // navigate to the vote poll screen if `id` param is provided
                if let params = components.queryItems {
                    let id = params.first { $0.name == "id" }
                    if let id = id {
                        let voteVC = VoteViewController()
                        voteVC.pollId = id.value
                        navigator?.pushViewController(voteVC, animated: true)
                    }
                }
            case .create:
                // navigate to the create poll screen
                let createVC = CreatePollViewController()
                if let params = components.queryItems {
                    let title = params.first { $0.name == "title" }
                    if let title = title {
                        createVC.pollTitleTF.text = title.value
                    }
                    navigator?.pushViewController(createVC, animated: true)
                }
            case .main:
                navigator?.setViewControllers([PollViewController()], animated: true)
            }
        }
        
    }
}
