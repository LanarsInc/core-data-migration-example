# Core Data migration Unit Test

You can spend less time for testing heavyweight migration using Unit tests. Rather than install the previous app version, generate data, install the newest version, you can write simple unit test.

## Steps for testing:
- Create Core Data Stack based on old data model version;
- Generate testing data;
- Create temporary Core Data Stack;
- Migrate persistent store data from old store to temporary store;
- Delete old persistent store;
- Move temporary persistent store to old location;
- Fetch migrated data from store using new Core Data Stack;
- Test Fetched data.
