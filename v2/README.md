# Heavyweight migration (from v2 to v3)

## Steps:

- Create a new data model version:
  - Select CoreDataMigrationExample.xcdatamodeld file -> Editor (on Menu bar) -> Add Model Version… -> Select `Based on model` to v2 -> Fill in CoreDataMigrationExample v3;
- Create two entities in data model called PrivateMessage and PublicMessage (in CoreDataMigrationExample v3.xcdatamodeld);
- In right pane in Data Model Inspector select Message entity to Parent Entity;
- Fill in corresponding class names and select current module;
- Remove isPrivate boolean value field from Message entity;
- Change MessagesListViewControllerV2 class to MessagesListViewControllerV3 in Main.storyboard;
- Change CreateMessageViewControllerV2 class to CreateMessageViewControllerV3 in Main.storyboard;
- Add UISegmentControl to navigationItem in MessagesListViewControllerV3 and connect with IBAction showMessages: as valueChanged action;
- Change segment titles to Public and Private respectively;
- Create mapping model:
  - File (on Menu bar) -> New -> File… -> Core Data -> Mapping Model;
  - Select v2 as Source Data Model;
  - Select v3 as Target Data Model;
  - Enter name MessageToPrivateAndPublic 
- Create NSEntityMigrationPolicy subclass (for example MessageToPrivateAndPublicPolicy);
- Open MessageToPrivateAndPublicPolicy.swift file, import CoreData framework;
- Override createDestinationInstances method with following implementation:

```swift
override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
    
    print(#function)
    
    if sInstance.entity.name == "Message" {
      let title = sInstance.primitiveValue(forKey: "title") as! String
      let text = sInstance.primitiveValue(forKey: "text") as! String
      let dateCreated = sInstance.primitiveValue(forKey: "dateCreated") as! Date
      let isPrivate = sInstance.primitiveValue(forKey: "isPrivate") as? Bool
      
      let entityName = isPrivate == true ? "PrivateMessage" : "PublicMessage"
      
      let message = NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                        into: manager.destinationContext)
      message.setValue(title, forKey: "title")
      message.setValue(text, forKey: "text")
      message.setValue(dateCreated, forKey: "dateCreated")
    }
  }
  ```
  
- Fill in NSEntityMigrationPolicy subclass name into Custom Policy field for MessageToMessage entity mapping in Mapping model; (example, CoreDataMigrationExample.MessageToPrivateAndPublicPolicy)
- Choose v3 in data model (CoreDataMigrationExample.xcdatamodeld);
- Run the app.
