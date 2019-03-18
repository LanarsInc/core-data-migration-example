//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import CoreData
import UIKit

class MessageToPrivateAndPublicPolicy: NSEntityMigrationPolicy {

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
}
