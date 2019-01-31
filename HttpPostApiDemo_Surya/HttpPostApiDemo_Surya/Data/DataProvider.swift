//
//  DataProvider.swift
//  HttpPostApiDemo_Surya
//
//  Created by Toor, Sanju on 30/01/19.
//  Copyright © 2019 Toor, Sanju. All rights reserved.
//

import CoreData

let dataErrorDomain = "dataErrorDomain"

enum DataErrorCode: NSInteger {
    case networkUnavailable = 101
    case wrongDataFormat = 102
}

class DataProvider {
    private let persistentContainer: NSPersistentContainer
    private let repository: APIService
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    init(persistentContainer: NSPersistentContainer, repository: APIService) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }
    
    func fetchUsersDetails(post: Post, completion: @escaping(Error?) -> Void) {
        repository.submitPost(post: post) { jsonDictionary, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let jsonDictionary = jsonDictionary else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
            
            _ = self.syncUserDetails(jsonDictionary: jsonDictionary, taskContext: taskContext)
            
            completion(nil)
        }
    }
    
    private func syncUserDetails(jsonDictionary: [[String: Any]], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            let emailIds = jsonDictionary.map { $0["emaiId"] as? String }.compactMap { $0 }
            let firstName = jsonDictionary.map { $0["firstName"] as? String }.compactMap { $0 }
            let lastName = jsonDictionary.map { $0["lastName"] as? String }.compactMap { $0 }
            let imageUrls = jsonDictionary.map { $0["imageUrl"] as? String }.compactMap { $0 }
            matchingEpisodeRequest.predicate = NSPredicate(format: "emailId in %@", argumentArray: [emailIds])
            matchingEpisodeRequest.predicate = NSPredicate(format: "firstName in %@", argumentArray: [firstName])
            matchingEpisodeRequest.predicate = NSPredicate(format: "lastName in %@", argumentArray: [lastName])
            matchingEpisodeRequest.predicate = NSPredicate(format: "imageUrl in %@", argumentArray: [imageUrls])

            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

//             Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult

                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }

            // Create new records.
            for usersDictionary in jsonDictionary {
                
                guard let user = NSEntityDescription.insertNewObject(forEntityName: "Users", into: taskContext) as? Users else {
                    print("Error: Failed to create a new Film object!")
                    return
                }
                
                do {
                    try user.update(with: usersDictionary)
                } catch {
                    print("Error: \(error)\nThe quake object will be deleted.")
                    taskContext.delete(user)
                }
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
    
}
