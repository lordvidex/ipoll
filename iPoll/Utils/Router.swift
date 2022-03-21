//
//  Router.swift
//  iPoll
//
//  Created by Evans Owamoyo on 21.03.2022.
//

import Foundation
import UIKit

typealias FailureCallBack = (String) -> Void

class Router {
    // MARK: singleton
    static let shared = Router()
    
    // MARK: variables
    private init () {}
    
    private weak var window: UIWindow?
    
    private static var navigator: UINavigationController? {
        return Router.shared.window?.rootViewController as? UINavigationController
    }
    
    // MARK: - functions
    static func configure(with window: UIWindow) {
        Router.shared.window = window
    }
    
    
    // uses the shared window instance to navigate to pages
    static func to(_ url: URL, failedWith reason: FailureCallBack? = nil) {
        if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
           let host = components.host,
           let scheme = components.scheme,
           let params = components.queryItems {
            
            // check if the scheme is valid
            if scheme.lowercased() != "ipoll" {
                reason?("Invalid QRCode / Link")
                return
            }
            
            // parse the hosts
            //
            switch host {
                    
                case "join":
                    // navigate to the join poll screen
                    let joinPollViewContoller = JoinPollViewController()
                    let id = params.first { $0.name == "id" }
                    if let id = id {
                        joinPollViewContoller.pollIdTF.text = id.value
                    }
                    navigator?.pushViewController(joinPollViewContoller, animated: true)
                    
                case "poll":
                    // navigate to the vote poll screen if `id` param is provided
                    let id = params.first { $0.name == "id" }
                    if let id = id {
                        let voteVC = VoteViewController()
                        voteVC.pollId = id.value
                        navigator?.pushViewController(voteVC, animated: true)
                    }
                    
                case "create":
                    // navigate to the create poll screen
                    let createVC = CreatePollViewController()
                    
                    let title = params.first { $0.name == "title" }
                    if let title = title {
                        createVC.pollTitleTF.text = title.value
                    }
                    navigator?.pushViewController(createVC, animated: true)
                
                default:
                        reason?("Unrecognized method or QRCode")
                    return
            }
        }
        
    }
}
