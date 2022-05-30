//
//  SceneDelegate.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.02.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let navController = UINavigationController(rootViewController: PollViewController())
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        // configure router
        Router.configure(with: window!)
        print("Router configured")
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            Router.to(url)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        PersistenceService.shared.saveContext()
    }

}
