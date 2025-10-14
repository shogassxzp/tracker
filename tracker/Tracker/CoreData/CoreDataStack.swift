import Foundation
import CoreData

final class CoreDataStack {
    var viewContext : NSManagedObjectContext {
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
    
    func saveContex(){
        let context = viewContext
        
        guard context.hasChanges else {return}
        
        do{
            try context.save()
            print("context saved")
        } catch {
            context.rollback()
        }
    }
    
    func backgroundContext() ->NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}
