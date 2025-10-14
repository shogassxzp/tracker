import CoreData
import UIKit

// MARK: - TrackerCategoryStore Protocol
protocol TrackerCategoryStoreProtocol {
    func addCategory(_ category: TrackerCategory) throws
    func fetchCategories() throws -> [TrackerCategory]
    func updateCategory(_ category: TrackerCategory) throws
    func deleteCategory(_ category: TrackerCategory) throws
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func addCategory(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryEntity(context: context)
        categoryEntity.id = category.id
        categoryEntity.title = category.title
        try context.save()
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let categoryEntities = try context.fetch(fetchRequest)
        return categoryEntities.map { entity in
            let id = entity.id ?? UUID()
            let title = entity.title ?? "Без категории"
            
            return TrackerCategory(id: id, title: title)
        }
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
