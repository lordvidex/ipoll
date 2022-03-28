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
    /// returns all stored polls 
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
    
    /// returns a Poll object or nil if such object with provided `id` does not exist
    func fetchPoll(with id: String) -> Poll? {
        fetch(entity: PollEntity.self, with: id)?.toPoll()
    }
    
    /**
      * `CREATE` & `UPDATE` (WRITES) to the database a new poll if it did not exist before
     */
    func savePoll(_ poll: Poll) {
        
        // create the option entities
        let pollOptionEntities = poll.options?.map { option -> PollOptionEntity in
            let votes = option.votesId.map { string -> VoteEntity in
                let voteEntity = fetch(entity: VoteEntity.self, with: string) ?? VoteEntity(context: context)
                voteEntity.id = string
                return voteEntity
            }
            
            let optionEntity = fetch(entity: PollOptionEntity.self, with: option.id) ?? PollOptionEntity(context: context)
            optionEntity.copyProperties(of: option, with: votes)
            return optionEntity
        }
        
        // create or update the poll
        let pollEntity = fetch(entity: PollEntity.self, with: poll.id) ?? PollEntity(context: context)
        pollEntity.copyProperties(of: poll, with: pollOptionEntities ?? [])
        saveContext()
    }
    
    // MARK: - Helper Methods
    /// Fetches a PollEntity from the CoreData stack or `nil` if it does not exist
    private func fetch<T: NSManagedObject>(entity: T.Type, with id: String) -> T? {
        let request = T.fetchRequest() as! NSFetchRequest<T>
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let fetchedEntities = try context.fetch(request)
            return fetchedEntities.first
        } catch {
            print(error)
            return nil
        }
    }
    
    
}
