//
//  Assembler.swift
//  iPoll
//
//  Created by Evans Owamoyo on 01.04.2022.
//

import UIKit


final class Assembler {
    
    // FUNCTION must be called first to initialize all services and viewModels
    func assemble() -> UIViewController {
        // MARK: - services
        let networkService = NetworkService(url: "https://llopi.herokuapp.com/v1")
        
        let persistentService = PersistenceService()
        
        // MARK: - viewModel
        let viewModel = PollViewModel(networkService: networkService, persistentService: persistentService)
        
        // MARK: Views
        let pollViewController = PollViewController(pollViewModel: viewModel)
        let navController = UINavigationController(rootViewController: pollViewController)
        
        return navController
    }
}
