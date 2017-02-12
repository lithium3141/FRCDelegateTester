This sample application sets up a basic Core Data stack and
NSFetchedResultsController in order to check how delegate messages are
delivered. To my knowledge, Core Data makes no guarantees about the ordering of
these messages; if you know otherwise, please [get in
touch](https://twitter.com/timothyekl).

## Usage

After cloning the repo, run the app directly from Xcode. Have the console open
in Xcode to watch results.

The app manages an in-memory managed object context, in which you can manipulate
objects using the three steppers. After setting values into each field, click
"Go" to perform the specified operations in a batch. Each call to an
NSFetchedResultsControllerDelegate method will be logged to the console.

There are two caveats on the operations you can perform:

* Making no changes (i.e. setting 0 for all fields) will produce no output.
* You cannot update and delete more objects combined than exist in the MOC. The
  app applies each change to a unique object, so there must already be at least
  `updates + deletes` objects existing in the MOC. A console message will warn
  you if this is requirement is violated.
