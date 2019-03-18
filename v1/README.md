# Lightweight migration (from v1 to v2)

## Steps:
- Run the app and create few messages (They will be migrated to v2);
- Create a new data model version:
  - Select CoreDataMigrationExample.xcdatamodeld file -> Editor (on Menu bar) -> Add Model Version... -> Fill in CoreDataMigrationExample v2
- Rename body field to text in: 
  - Message entity in data model (CoreDataMigrationExample.xcdatamodeld version 2);
  - Message model (Message.swift);
  - Other class where body field is used;
  - Add renameId text to Data Model Inspector for body attribute (CoreDataMigrationExample.xcdatamodeld version 1).
- Add isPrivate boolean value field to Message entity in data model version 2;
- Change MessagesListViewController class to MessagesListViewControllerV2 in Main.storyboard;
- Control-drag from the navigation controller to CreateMessageViewControllerV2 and select the root view controller relationship segue. Main.storyboard;
- Choose v2 in data model:
  - Select CoreDataMigrationExample.xcdatamodeld file;
  - In the File Inspector pane on the right, there is a selection menu toward the bottom called Model Version.
  - Change that selection to match the name of the new data model, CoreDataMigrationExample v2.
- Run the app.
