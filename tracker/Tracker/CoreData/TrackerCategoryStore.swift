import CoreData
import UIKit

protocol TrackerCategoryStoreProtocol {
    func fetchAllCategories() throws -> [TrackerCategory]
    func addCategory(_ category: TrackerCategory) throws
    func updateCategory(_ category: TrackerCategory) throws
    func deleteCategory(_ category: TrackerCategory) throws
}

final class TrackerCategoryStore: TrackerCategoryStoreProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAllCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        let categoryEntities = try context.fetch(fetchRequest)

        return categoryEntities.compactMap { entity in
            guard let id = entity.id,
                  let title = entity.title else {
                return nil
            }

            return TrackerCategory(id: id, title: title, trackers: [])
        }
    }

    func addCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        let existingCategories = try context.fetch(fetchRequest)
        guard existingCategories.isEmpty else {
            return
        }
        
        let categoryEntity = TrackerCategoryEntity(context: context)
        categoryEntity.id = category.id
        categoryEntity.title = category.title
        
        Dependencies.shared.coreDataStack.saveContext()
    }

    func updateCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        if let categoryEntity = try context.fetch(fetchRequest).first {
            categoryEntity.title = category.title
            try context.save()
        }
    }

    func deleteCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        if let categoryEntity = try context.fetch(fetchRequest).first {
            context.delete(categoryEntity)
            try context.save()
        }
    }
}
