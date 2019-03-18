//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import UIKit

class MessageTableViewCell: UITableViewCell {

  // MARK: - Properties
  
  var message: Message? {
    didSet {
      guard let message = message else { return }
      updateMessageInfo(message: message)
    }
  }

  // MARK: - IBOutlets
  
  @IBOutlet fileprivate var messageTitle: UILabel!
  @IBOutlet fileprivate var messageCreateDate: UILabel!
}

// MARK: - Internal

@objc extension MessageTableViewCell {
  
  func updateMessageInfo(message: Message) {
    messageTitle.text = message.title
    messageCreateDate.text = message.dateCreated.description
  }
}
