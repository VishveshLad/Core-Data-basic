//
//  CoreDataManager.swift


import Foundation
import CoreData

enum CoreDataContextEnum {
    case MainQueueContext,
    PrivateContext
}

enum entityNameEnum: String {
    case Tbl_Name = "Tbl_Name"
}

class CoreDataManager: NSObject {
    //MARK:- Variables
    static let sharedInstance = CoreDataManager()
    
    private override init() {
        super.init()
    }
    
    //ManagedObject Context for CoreData
    // MAIN CONTEXT
    lazy var mainQueueContext: NSManagedObjectContext? = {
        let parentContext = self.masterContext
        
        if parentContext == nil {
            return nil
        }
        
        var mainQueueContext =
            NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainQueueContext.parent = parentContext
        mainQueueContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return mainQueueContext
    }()
    
    // BACKGROUND CONTEXT
    /// Creates and configures a private queue context.
    /*lazy var backgroundQueueContext: NSManagedObjectContext = {
        let backgroundQueueContext = self.persistentContainer.newBackgroundContext()
        backgroundQueueContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundQueueContext.automaticallyMergesChangesFromParent = true
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        backgroundQueueContext.undoManager = nil
        return backgroundQueueContext
    }()*/
    
    // PRIVATE CONTEXT
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let parentContext = self.mainQueueContext
        
        var privateQueueContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateQueueContext.parent = parentContext
        privateQueueContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return privateQueueContext
    }()
    
    func getContext(coreDataContextEnum: CoreDataContextEnum = .MainQueueContext) -> NSManagedObjectContext{
        switch coreDataContextEnum {
        case .MainQueueContext:
            return mainQueueContext!
        case .PrivateContext:
            return self.privateManagedObjectContext
        }
    }
    
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // CUSTOM WAY TO CREEATE DB
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        guard let modelURL = Bundle.main.url(forResource: "db", withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        return mom
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("db.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        print("\n***** SQLite Path ****** \n\n\(url as Any)\n\n ***** SQLite Path ****** \n")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    // PRIVATE MASTER CONTEXT
    private lazy var masterContext: NSManagedObjectContext? = {
        var masterContext =
            NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // FOR CUSTOM DB
        let coordinator = self.persistentStoreCoordinator
        masterContext.persistentStoreCoordinator = coordinator
         
//        masterContext.parent = persistentContainer.viewContext
        masterContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return masterContext
    }()
    
    // PRIVATE MASTER CONTEXT
//    private lazy var mainViewContext: NSManagedObjectContext? = persistentContainer.viewContext
    
    // DEFAULT WAY TO CREATE DB WHICH AUTO GENERATED BY SYSTEM
    
    /*lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "db")
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        let url = self.applicationDocumentsDirectory.appendingPathComponent("db.sqlite")
        description.url = url
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }else{
                print("\n***** SQLite Path ****** \n\n\(url as Any)\n\n ***** SQLite Path ****** \n")
            }
            
        }
        return container
    }()*/
    
    
    // MARK: - Core Data Saving support
    func saveContext() {
        
        /*CoreDataManager.sharedInstance.getContext(coreDataContextEnum: .BackgroundContext).perform {
            if CoreDataManager.sharedInstance.getContext(coreDataContextEnum: .BackgroundContext).hasChanges{
                do {
                    //Saves in private context
                    try CoreDataManager.sharedInstance.getContext(coreDataContextEnum: .BackgroundContext).save()
                    print("SAVE CONTEXT: background Context")
                } catch {
                    //fatalError("Failure to save context: \(error)")
                    print("Failure to save background context: \(error)")
                }
            }else{
//                print("SAVE CONTEXT: No changes in background Context")
            }
        }*/
        
        CoreDataManager.sharedInstance.getContext(coreDataContextEnum: .PrivateContext).perform {
            if CoreDataManager.sharedInstance.getContext(coreDataContextEnum: .PrivateContext).hasChanges{
                do {
                    //Saves in private context
                    try CoreDataManager.sharedInstance.getContext(coreDataContextEnum: .PrivateContext).save()
                    print("SAVE CONTEXT: Private Context")
                } catch {
                    //fatalError("Failure to save context: \(error)")
                    print("Failure to save private context: \(error)")
                }
            }else{
//                print("SAVE CONTEXT: No changes in Private Context")
            }
        }
            
        CoreDataManager.sharedInstance.getContext().performAndWait({
            if CoreDataManager.sharedInstance.getContext().hasChanges{
                do {
                    //print("SAVE CONTEXT: save changes in Main Context")
                    // Saves the changes from the child to the main context to be applied properly
                    try CoreDataManager.sharedInstance.getContext().save()
                    print("SAVE CONTEXT: Main Context")
                } catch {
                    // fatalError("Failure to save context: \(error)")
                    print("Failure to save main queue context: \(error)")
                }
            }else{
//                print("SAVE CONTEXT: No changes in Main Context")
            }
        })
        
        CoreDataManager.sharedInstance.masterContext?.performAndWait({
            if CoreDataManager.sharedInstance.masterContext?.hasChanges ?? false{
                do {
                    //print("SAVE CONTEXT: save changes in Master Context")
                    // Saves the changes from the child to the main context to be applied properly
                    try CoreDataManager.sharedInstance.masterContext?.save()
                    print("SAVE CONTEXT: Master Context")
                } catch {
                    // fatalError("Failure to save context: \(error)")
                    print("Failure to save master context: \(error)")
                }
            }else{
//                print("SAVE CONTEXT: No changes in Master Context")
            }
        })
        
        /*CoreDataManager.sharedInstance.mainViewContext?.performAndWait ({
            if CoreDataManager.sharedInstance.mainViewContext?.hasChanges ?? false {
                do {
                    //print("SAVE CONTEXT: save changes in Master Context")
                    // Saves the changes from the child to the main context to be applied properly
                    try CoreDataManager.sharedInstance.mainViewContext?.save()
                    print("SAVE CONTEXT: Main View Context")
                } catch {
                    // fatalError("Failure to save context: \(error)")
                    print("Failure to save Main View context: \(error)")
                }
            }else{
                //                print("SAVE CONTEXT: No changes in Main View Context")
            }
        })*/
    }
    
    
    //MARK:- Private Methods
    //Clear all data from Core data
    public func clearCoreDataStore() {
        let entities = self.persistentStoreCoordinator.managedObjectModel.entities // CUSTOM
//        let entities = self.persistentContainer.managedObjectModel.entities // DEFAULT
        for entity in entities {
            if let entityName = entity.name{
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try self.getContext().execute(deleteReqest)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //Remove all objects from entity
    func removeObjectsFor(entityName:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let objects = try self.getContext().fetch(fetchRequest)
            for object in objects {
                print("Deleting \(entityName) object")
                self.getContext().delete(object as! NSManagedObject)
                try self.getContext().save()
            }
        } catch  {
            print("Failed to remove \(entityName) object: \(error.localizedDescription)")
        }
    }
    //MARK: - COMMON METOHDS
    //Get auto incremented id for entity
    func getIncrementedId(idKeyName: String, entityName: String, context: NSManagedObjectContext) -> Int64 {
        var incrementedId: Int64 = 1
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: idKeyName, ascending: false)
        fetchRequest.sortDescriptors = [idDescriptor]
        fetchRequest.fetchLimit = 1
        
        do {
            let list = try context.fetch(fetchRequest)
            if list.count == 1 {
                incrementedId = ((list[0] as AnyObject).value(forKey: idKeyName) as! Int64) + 1
            }
            return incrementedId
        } catch let error as NSError {
            print("LOG: getIncrementedId \(error.userInfo)")
            return incrementedId
        }
    }
    
    //Check & return is matching record with predicate exist
    func getRecordIfExistIn(predicate: NSPredicate?, entityName: String, context: NSManagedObjectContext) -> (isRecordExist: Bool, Records: [Any]?)? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest)
            if (result.count > 0) {
                return (true, result)
            }
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
        
        return (false, nil)
    }
    
    // Batch insert data.
    func batchInsertData(entity: entityNameEnum, dictData: [[String: Any]], context: NSManagedObjectContext) {
        context.perform {
            let batchInsertRequest = NSBatchInsertRequest(entityName: entity.rawValue, objects: dictData)
            batchInsertRequest.resultType = .statusOnly
            do {
                _ = try context.execute(batchInsertRequest) as? NSBatchInsertResult
//                print(batchInsertResult?.result as? Bool)
            }catch {
                print(error.localizedDescription)
            }
            CoreDataManager.sharedInstance.saveContext()
        }
    }
    
    // Batch update data self own object
    func batchUpdateData(entity: entityNameEnum, predicate: NSPredicate? , dictData: [String: Any], context: NSManagedObjectContext) {
        
        // Initialize Batch Update Request
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: entity.rawValue)
        
        // Configure Batch Update Request
        batchUpdateRequest.resultType = .statusOnlyResultType
        batchUpdateRequest.predicate = predicate
        batchUpdateRequest.propertiesToUpdate = dictData //["done": NSNumber(value: true)]
        
        do {
            // Execute Batch Request
            guard let _ = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult else {
                return
            }
            //            print(batchUpdateResult.result as? Bool)
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
        CoreDataManager.sharedInstance.saveContext()
    }
    
    // Batch delete data self own object
    func batchDeleteData(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext) {
        // Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // Configure Batch Update Request
        batchDeleteRequest.resultType = .resultTypeStatusOnly
        do {
            // Execute Batch Request
            guard let _ =  try context.execute(batchDeleteRequest) as? NSBatchDeleteResult else {
                return
            }
//            print(batchDeleteRsult.result as? Bool)
        } catch {
            let deleteError = error as NSError
            print("\(deleteError), \(deleteError.userInfo)")
        }
        CoreDataManager.sharedInstance.saveContext()
    }
}
