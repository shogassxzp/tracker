import CoreData
import Foundation

final class Dependencies {
    static let shared = Dependencies()

    lazy var coreDataStack: CoreDataStack = {
        CoreDataStack(modelName: "TrackerDataModel")
    }()

    lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(context: coreDataStack.viewContext)
    }()

    lazy var categoryStore: TrackerCategoryStoreProtocol = {
        TrackerCategoryStore(context: coreDataStack.viewContext)
    }()

    lazy var recordStore: TrackerRecordStoreProtocol = {
        TrackerRecordStore(context: coreDataStack.viewContext)
    }()

    private init() {}
}
