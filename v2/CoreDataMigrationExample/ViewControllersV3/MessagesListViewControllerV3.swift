//  Copyright © 2019 Lanars. All rights reserved.
//  https://lanars.com/
//

import UIKit
import CoreData

class MessagesListViewControllerV3: UITableViewController {

  // MARK: - Properties
  
  fileprivate lazy var stack: CoreDataStack = CoreDataStack()

  private var isPublicSelected = true
  private var messages: NSFetchedResultsController<Message> {
    return isPublicSelected ? publicMessages : privateMessages
  }
  fileprivate lazy var publicMessages: NSFetchedResultsController<Message> = {
    let context = stack.managedContext
    let request = PublicMessage.fetchRequest() as! NSFetchRequest<Message>
    let dateCreatedSortDescriptor = NSSortDescriptor(key: #keyPath(Message.dateCreated), ascending: false)
    
    request.sortDescriptors = [dateCreatedSortDescriptor]
    
    let messages = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    messages.delegate = self
    return messages
  }()
  
  fileprivate lazy var privateMessages: NSFetchedResultsController<Message> = {
    let context = stack.managedContext
    let request = PrivateMessage.fetchRequest() as! NSFetchRequest<Message>
    let dateCreatedSortDescriptor = NSSortDescriptor(key: #keyPath(Message.dateCreated), ascending: false)
    
    request.sortDescriptors = [dateCreatedSortDescriptor]
    
    let messages = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    messages.delegate = self
    return messages
  }()

  // MARK: - View Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadData()
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
  
  private func loadData() {
    do {
      isPublicSelected ? try publicMessages.performFetch() : try privateMessages.performFetch()
    } catch {
      print("Error: \(error)")
    }
    
    tableView.reloadData()
  }
}

// MARK: - IBActions

extension MessagesListViewControllerV3 {

  @IBAction func goToMessageList(_ segue: UIStoryboardSegue) {
    stack.saveContext()
  }
    
  @IBAction func showMessages(_ sender: UISegmentedControl) {
    isPublicSelected = sender.selectedSegmentIndex == 0
    loadData()
  }
}

// MARK: - UITableViewDataSource

extension MessagesListViewControllerV3 {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return messages.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.sections?[section].numberOfObjects ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
    cell.message = messages.object(at: indexPath)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return messages.sections?[section].name
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MessagesListViewControllerV3: NSFetchedResultsControllerDelegate {

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
