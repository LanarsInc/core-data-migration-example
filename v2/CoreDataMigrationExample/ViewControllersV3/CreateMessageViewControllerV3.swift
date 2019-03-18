//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import UIKit
import CoreData

class CreateMessageViewControllerV3: UIViewController, MOMAccesible {

  // MARK: - Properties
  
  var managedObjectContext: NSManagedObjectContext?
  private var isPrivate = false
  lazy var message: Message? = {
    guard let context = self.managedObjectContext else { return nil }
    return isPrivate ? PrivateMessage(context: context) : PublicMessage(context: context)
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
    guard let nextViewController = segue.destination as? MessageDisplayable else { return }

    nextViewController.message = message
  }
  
  @IBAction func messageAccessSwitchAction(_ sender: UISwitch) {
    isPrivate = sender.isOn
  }
}

// MARK: - IBActions

extension CreateMessageViewControllerV3 {

  @IBAction func saveMessage() {
    guard
      let message = message,
      let managedObjectContext = managedObjectContext
    else {
        return
    }

    message.title = titleField.text ?? ""
    message.text = bodyField.text ?? ""

    do {
      try managedObjectContext.save()
    } catch let error as NSError {
      print("Error saving \(error)", terminator: "")
    }

    performSegue(withIdentifier: "goToMessageList", sender: self)
  }
}

// MARK: - UITextFieldDelegate

extension CreateMessageViewControllerV3: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    saveMessage()
    textField.resignFirstResponder()
    return false
  }
}
