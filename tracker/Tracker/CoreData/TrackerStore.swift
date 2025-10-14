import CoreData
import UIKit

// MARK: - TrackerStore Protocol
protocol TrackerStoreProtocol {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func fetchTrackers() throws -> [Tracker]
    func fetchTrackers(for category: TrackerCategory) throws -> [Tracker]
    func updateTracker(_ tracker: Tracker) throws
    func deleteTracker(_ tracker: Tracker) throws
}

// MARK: - TrackerStore
final class TrackerStore: NSObject, TrackerStoreProtocol {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.title = tracker.title
        trackerEntity.color = tracker.color.hexString
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as NSArray
        trackerEntity.isHabit = tracker.isHabit
        
        // Найдем или создадим категорию
        let categoryFetchRequest = TrackerCategoryEntity.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        if let existingCategory = try context.fetch(categoryFetchRequest).first {
            // Устанавливаем отношение, а не присваиваем строку
            trackerEntity.categoryy = existingCategory
        } else {
            let categoryEntity = TrackerCategoryEntity(context: context)
            categoryEntity.id = category.id
            categoryEntity.title = category.title
            trackerEntity.categoryy = categoryEntity
        }
        
        try context.save()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        guard let trackerEntities = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return trackerEntities.compactMap { entity in
            guard let id = entity.id,
                  let title = entity.title,
                  let colorHex = entity.color,
                  let emoji = entity.emoji,
                  let schedule = entity.schedule as? [Weekday],
                  let categoryEntity = entity.categoryy,
                  let categoryId = categoryEntity.id,
                  let categoryTitle = categoryEntity.title else {
                return nil
            }
            
            let color = UIColor.color(from: colorHex)
            let category = TrackerCategory(id: categoryId, title: categoryTitle)
            
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isHabit: entity.isHabit,
                category: category
            )
        }
    }
    
    func fetchTrackers(for category: TrackerCategory) throws -> [Tracker] {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category.id == %@", category.id as CVarArg)
        
        let trackerEntities = try context.fetch(fetchRequest)
        return trackerEntities.compactMap { entity in
            guard let id = entity.id,
                  let title = entity.title,
                  let colorHex = entity.color,
                  let emoji = entity.emoji,
                  let schedule = entity.schedule as? [Weekday] else {
                return nil
            }
            
            let color = UIColor.color(from: colorHex)
            
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isHabit: entity.isHabit,
                category: category
            )
        }
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerEntity = try context.fetch(fetchRequest).first {
            trackerEntity.title = tracker.title
            trackerEntity.color = tracker.color.hexString
            trackerEntity.emoji = tracker.emoji
            trackerEntity.schedule = tracker.schedule as NSArray
            trackerEntity.isHabit = tracker.isHabit
            
            if let currentCategory = trackerEntity.categoryy,
               currentCategory.id != tracker.category.id {
                let categoryFetchRequest = TrackerCategoryEntity.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.category.id as CVarArg)
                
                if let newCategory = try context.fetch(categoryFetchRequest).first {
                    trackerEntity.categoryy = newCategory
                }
            }
            
            try context.save()
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerEntity = try context.fetch(fetchRequest).first {
            context.delete(trackerEntity)
            try context.save()
        }
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}
