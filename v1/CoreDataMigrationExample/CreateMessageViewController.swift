//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import UIKit
import CoreData

class CreateMessageViewController: UIViewController, MOMAccesible {

  // MARK: - Properties
  
  var managedObjectContext: NSManagedObjectContext?
  lazy var message: Message? = {
    guard let context = self.managedObjectContext else { return nil }
    return Message(context: context)
  }()

  // MARK: - IBOutlets
  
  @IBOutlet fileprivate var titleField: UITextField!
  @IBOutlet fileprivate var bodyField: UITextView!

  // MARK: - View Life Cycle
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    titleField.becomeFirstResponder()
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destinationViewController = segue.destination as? MessageDisplayable else { return }

    destinationViewController.message = message
  }
}

// MARK: - IBActions

extension CreateMessageViewController {

  @IBAction func saveMessage() {
    guard
      let message = message,
      let managedObjectContext = managedObjectContext
    else {
        return
    }

    message.title = titleField.text ?? ""
    message.body = bodyField.text ?? ""

    do {
      try managedObjectContext.save()
    } catch let error as NSError {
      print("Error saving \(error)", terminator: "")
    }

    performSegue(withIdentifier: "goToMessageList", sender: self)
  }
}

// MARK: - UITextFieldDelegate

extension CreateMessageViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    saveMessage()
    textField.resignFirstResponder()
    return false
  }
}
