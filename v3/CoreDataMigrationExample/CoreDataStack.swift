//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import CoreData

protocol MOMAccesible: class {
  var managedObjectContext: NSManagedObjectContext? { get set }
}

class CoreDataStack {
  
  // MARK: - Properties
  
  lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext
  
  var savingContext: NSManagedObjectContext {
    return storeContainer.newBackgroundContext()
  }
  
  private let modelName: String = "CoreDataMigrationExample"
  private let storeName: String = "CoreDataMigrationExample"
  
  var storeURL: URL {
    let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
    let storePath = storePaths.first! as NSString
    
    do {
      try FileManager.default.createDirectory(atPath: storePath as String, withIntermediateDirectories: true)
    } catch {
      print("Error creating storePath \(storePath): \(error)")
    }
    
    let sqliteFilePath = storePath.appendingPathComponent(storeName + ".sqlite")
    return URL(fileURLWithPath: sqliteFilePath)
  }
  
  lazy var storeDescription: NSPersistentStoreDescription = {
    let description = NSPersistentStoreDescription(url: self.storeURL)
    return description
  }()
  
  private lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.persistentStoreDescriptions = [self.storeDescription]
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error {
        fatalError("Unresolved error \(error)")
      }
    }
    return container
  }()
}

extension CoreDataStack {
  
  func saveContext () {
    guard managedContext.hasChanges else { return }
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
  }
}
