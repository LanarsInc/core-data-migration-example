//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import CoreData

class Message: NSManagedObject {
  @NSManaged var title: String
  @NSManaged var text: String
  @NSManaged var dateCreated: Date!
  @NSManaged var isPrivate: Bool

  override func awakeFromInsert() {
    super.awakeFromInsert()
    dateCreated = Date()
  }
}

class PublicMessage: Message { }
class PrivateMessage: Message { }
