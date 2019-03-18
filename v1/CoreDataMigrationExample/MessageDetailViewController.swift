//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import UIKit

protocol MessageDisplayable: class {
  var message: Message? { get set }
}

class MessageDetailViewController: UIViewController, MessageDisplayable {

  // MARK: - Properties
  
  var message: Message? {
    didSet {
      updateMessageInfo()
    }
  }

  // MARK: - IBOutlets
  
  @IBOutlet fileprivate var titleField: UILabel!
  @IBOutlet fileprivate var bodyField: UITextView!

  // MARK: - View Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateMessageInfo()
  }
}

// MARK: - Internal
extension MessageDetailViewController {

  func updateMessageInfo() {
    guard
      isViewLoaded,
      let message = message
    else {
        return
    }

    titleField.text = message.title
    bodyField.text = message.body
  }
}
