//
//  PersistenceService.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.03.2022.
//

import Foundation
import CoreData


protocol PersistenceServiceProtocol {
    func fetchPolls() -> [Poll]
    func fetchPoll(with id: String) -> Poll?
    func savePoll(_ poll: Poll)
}

class PersistenceService: PersistenceServiceProtocol {
    
    static let shared = PersistenceService()
    
    private init() {}
    
    // Container
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iPoll")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // ViewContext
    lazy private var context = persistentContainer.viewContext
    
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    // MARK: - CRUD Functions
    func fetchPolls() -> [Poll] {
        let request = PollEntity.fetchRequest()
        do {
            let fetchedEntities = try context.fetch(request)
            return fetchedEntities.map { $0.toPoll() }
        } catch {
            print(error)
            return []
        }
    }
    
    func fetchPoll(with id: String) -> Poll? {
        let request = PollEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let fetchedEntities = try context.fetch(request)
            return fetchedEntities
                .map { $0.toPoll() }
                .first
        } catch {
            print(error)
            return nil
        }
    }
    
    func savePoll(_ poll: Poll) {
        // create the option entities
        let pollOptionEntities = poll.options?.map { option -> PollOptionEntity in
            let votes = option.votesId.map { string -> VoteEntity in
                let voteEntity = VoteEntity(context: context)
                voteEntity.id = string
                return voteEntity
            }
            let optionEntity = PollOptionEntity(context: context)
            optionEntity.copyProperties(of: option, with: votes)
            return optionEntity
        }
        
        // create the poll
        let pollEntity = PollEntity(context: context)
        pollEntity.copyProperties(of: poll, with: pollOptionEntities ?? [])
        saveContext()
    }
    
    
}
