import CoreData
import Foundation

final class CoreDataStack {
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private let modelName: String

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("store loaded: \(storeDescription)")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    init(modelName: String) {
        self.modelName = modelName
    }

    func saveContext() {
        let context = viewContext

        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
