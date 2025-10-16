import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers(_ trackers: [Tracker])
}

protocol TrackerStoreProtocol {
    var delegate: TrackerStoreDelegate? { get set }
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func fetchTrackers() throws -> [Tracker]
    func fetchTrackers(for category: TrackerCategory) throws -> [Tracker]
    func updateTracker(_ tracker: Tracker) throws
    func deleteTracker(_ tracker: Tracker) throws
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        guard context.concurrencyType == .mainQueueConcurrencyType else {
            throw NSError(domain: "TrackerStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Wrong context"])
        }

        let trackerEntity = TrackerEntity(context: context)

        guard !tracker.title.isEmpty else {
            context.delete(trackerEntity)
            throw NSError(domain: "TrackerStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty tracker title"])
        }
        trackerEntity.id = tracker.id
        trackerEntity.title = tracker.title
        trackerEntity.color = tracker.color.hexString
        trackerEntity.emoji = tracker.emoji
        let scheduleStrings = tracker.schedule.map { $0.rawValue }
        trackerEntity.schedule = scheduleStrings as NSArray
        trackerEntity.isHabit = tracker.isHabit

        let categoryFetchRequest = TrackerCategoryEntity.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        if let existingCategory = try context.fetch(categoryFetchRequest).first {
            trackerEntity.categoryr = existingCategory
        } else {
            let categoryEntity = TrackerCategoryEntity(context: context)
            categoryEntity.id = category.id
            categoryEntity.title = category.title
            trackerEntity.categoryr = categoryEntity
        }
        Dependencies.shared.coreDataStack.saveContext()
    }

    func fetchTrackers() throws -> [Tracker] {
        return convertToTrackers(fetchedResultsController?.fetchedObjects ?? [])
    }

    func fetchTrackers(for category: TrackerCategory) throws -> [Tracker] {
        let trackers = convertToTrackers(fetchedResultsController?.fetchedObjects ?? [])
        return trackers.filter { $0.category.id == category.id }
    }

    func updateTracker(_ tracker: Tracker) throws {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        if let trackerEntity = try context.fetch(fetchRequest).first {
            updateTrackerEntity(trackerEntity, with: tracker, category: tracker.category)
            Dependencies.shared.coreDataStack.saveContext()
        }
    }

    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        if let trackerEntity = try context.fetch(fetchRequest).first {
            context.delete(trackerEntity)
            Dependencies.shared.coreDataStack.saveContext()
        }
    }

    private func setupFetchedResultsController() {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true),
        ]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )

        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    private func updateTrackerEntity(_ entity: TrackerEntity, with tracker: Tracker, category: TrackerCategory) {
        entity.id = tracker.id
        entity.title = tracker.title
        entity.color = tracker.color.hexString
        entity.emoji = tracker.emoji
        let scheduleStrings = tracker.schedule.map { $0.rawValue }
        entity.schedule = scheduleStrings as NSArray
        entity.isHabit = tracker.isHabit

        let categoryFetchRequest = TrackerCategoryEntity.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        if let existingCategory = try? context.fetch(categoryFetchRequest).first {
            entity.categoryr = existingCategory
        } else {
            let categoryEntity = TrackerCategoryEntity(context: context)
            categoryEntity.id = category.id
            categoryEntity.title = category.title
            entity.categoryr = categoryEntity
        }
    }

    private func convertToTrackers(_ entities: [TrackerEntity]) -> [Tracker] {
        return entities.compactMap { entity in
            guard let id = entity.id,
                  let title = entity.title,
                  let colorHex = entity.color,
                  let emoji = entity.emoji,
                  let scheduleArray = entity.schedule as? [String],
                  let categoryEntity = entity.categoryr,
                  let categoryId = categoryEntity.id,
                  let categoryTitle = categoryEntity.title else {
                return nil
            }
            let schedule = scheduleArray.compactMap { Weekday(rawValue: $0) }
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
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let trackers = convertToTrackers(controller.fetchedObjects as? [TrackerEntity] ?? [])
        delegate?.didUpdateTrackers(trackers)
    }
}
