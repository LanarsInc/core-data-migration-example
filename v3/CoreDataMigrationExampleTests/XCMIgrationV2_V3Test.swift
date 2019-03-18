//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import CoreData
import XCTest

class XCMIgrationV2_V3Test: XCTestCase {
  
  private enum Version {
    case old
    case new
  
    var dataModelPath: String {
      switch self {
      case .old: return "CoreDataMigrationExample.momd/CoreDataMigrationExample v2"
      case .new: return "CoreDataMigrationExample.momd/CoreDataMigrationExample v3"
      }
    }
    
    var storeUrl: URL {
      switch self {
      case .old: return applicationDocumentsDirectory.appendingPathComponent("CoreDataMigrationExample v2.sqlite")
      case .new: return applicationDocumentsDirectory.appendingPathComponent("CoreDataMigrationExample v3.sqlite")
      }
    }
    
    private var applicationDocumentsDirectory: URL {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
  }
  
  let mappingModelName = "MessageToPrivateAndPublic"
  
  func testExample() {
    
    do {
      
      //
      // Generate test data
      //
      
      let oldUrl = Version.old.storeUrl
      
      XCTAssertNoThrow(try replaceStore(oldUrl))
      
      let oldManagedObjectModel = try managedObjectModel(forVersion: .old)
      let coordinator = try persistentStoreCoordinator(for: oldManagedObjectModel, at: oldUrl)
      let context = managedObjectContext(for: coordinator)
      
      XCTAssertNoThrow(try generateData(in: context))
      
      //
      // Migration
      //
      
      let newManagedObjectModel = try managedObjectModel(forVersion: .new)
      let mappingModel = generateMappingModel()
      
      let migrationManager = NSMigrationManager(sourceModel: oldManagedObjectModel, destinationModel: newManagedObjectModel)
      
      let newUrl = Version.new.storeUrl
      try migrationManager.migrateStore(from: oldUrl, sourceType: NSSQLiteStoreType, with: mappingModel, toDestinationURL: newUrl, destinationType: NSSQLiteStoreType)
      
      XCTAssertNoThrow(try replaceStore(oldUrl, withStore: newUrl))
      
      //
      // Validation
      //
      
      let newCoordinator = try persistentStoreCoordinator(for: newManagedObjectModel, at: oldUrl)
      let newManagedObjectContext = managedObjectContext(for: newCoordinator)
      
      let privateMessagesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateMessage")
      let privateMessages = try newManagedObjectContext.fetch(privateMessagesRequest) as! [NSManagedObject]
      XCTAssertEqual(privateMessages.count, 1)
      
      let publicMessagesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PublicMessage")
      let publicMessages = try newManagedObjectContext.fetch(publicMessagesRequest) as! [NSManagedObject]
      XCTAssertEqual(publicMessages.count, 1)
      
      let messageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
      let messages = try newManagedObjectContext.fetch(messageRequest) as! [NSManagedObject]
      XCTAssertEqual(messages.count, 2)
      
      //
      // Replace migrated store
      //
      
    } catch {
      print(error.localizedDescription)
    }
  }
}

extension XCMIgrationV2_V3Test {
  
  private func managedObjectModel(forVersion version: Version) throws -> NSManagedObjectModel {
    let modelUrl = Bundle.main.url(forResource: version.dataModelPath, withExtension: "mom")!
    let model = NSManagedObjectModel(contentsOf: modelUrl)
    XCTAssertNotNil(model)
    return model!
  }
  
  private func persistentStoreCoordinator(for model: NSManagedObjectModel, at url: URL) throws -> NSPersistentStoreCoordinator {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    return coordinator
  }
  
  private func managedObjectContext(for coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }
  
  private func generateMappingModel() -> NSMappingModel {
    let mappingModelUrl = URL(fileURLWithPath: Bundle.main.path(forResource: mappingModelName, ofType: "cdm") ?? "")
    let mappingModel = NSMappingModel(contentsOf: mappingModelUrl)
    XCTAssertNotNil(mappingModel)
    return mappingModel!
  }
  
  private func generateData(in context: NSManagedObjectContext) throws {
    
    //
    // Generate test data
    //
    
    let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context)
    message.setValue("test title 1", forKey: "title")
    message.setValue("test body 1", forKey: "text")
    message.setValue(true, forKey: "isPrivate")
    
    let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context)
    message2.setValue("test title 2", forKey: "title")
    message2.setValue("test body 2", forKey: "text")
    message2.setValue(false, forKey: "isPrivate")
    
    try context.save()
  }
  
  private func replaceStore(_ oldUrl: URL, withStore newUrl: URL? = nil) throws {
    
    //
    // Remove old version store and move new store to old location
    //
    
    if storeExists(at: oldUrl) {
      try FileManager.default.removeItem(at: oldUrl)
    }
    
    guard let destination = newUrl else { return }
    try FileManager.default.moveItem(at: destination, to: oldUrl)
  }
  
  private func storeExists(at url: URL) -> Bool {
    var isExisted = false
    do {
      isExisted = try url.checkResourceIsReachable()
    } catch {
      print(error.localizedDescription)
    }
    return isExisted
  }
}
