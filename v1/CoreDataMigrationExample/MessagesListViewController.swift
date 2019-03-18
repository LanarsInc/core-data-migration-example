//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import UIKit
import CoreData

class MessagesListViewController: UITableViewController {

  // MARK: - Properties
  
  fileprivate lazy var stack: CoreDataStack = CoreDataStack()

  fileprivate lazy var messages: NSFetchedResultsController<Message> = {
    let context = self.stack.managedContext
    let request = Message.fetchRequest() as! NSFetchRequest<Message>
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.dateCreated), ascending: false)]

    let messages = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    messages.delegate = self
    return messages
  }()

  // MARK: - View Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    do {
      try messages.performFetch()
    } catch {
      print("Error: \(error)")
    }

    tableView.reloadData()
  }

  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navController = segue.destination as? UINavigationController,
      let viewController = navController.topViewController as? MOMAccesible {
        viewController.managedObjectContext = stack.savingContext
    }

    if let detailView = segue.destination as? MessageDisplayable,
      let selectedIndex = tableView.indexPathForSelectedRow {
        detailView.message = messages.object(at: selectedIndex)
    }
  }
}

// MARK: - IBActions

extension MessagesListViewController {

  @IBAction func goToMessageList(_ segue: UIStoryboardSegue) {
    stack.saveContext()
  }
}

// MARK: - UITableViewDataSource

extension MessagesListViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let objects = messages.fetchedObjects
    return objects?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
    cell.message = messages.object(at: indexPath)
    return cell
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MessagesListViewController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    let wrapIndexPath: (IndexPath?) -> [IndexPath] = { $0.map { [$0] } ?? [] }

    switch type {
    case .insert:
      tableView.insertRows(at: wrapIndexPath(newIndexPath), with: .automatic)
    case .delete:
      tableView.deleteRows(at: wrapIndexPath(indexPath), with: .automatic)
    default:
      break
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
  }
}
