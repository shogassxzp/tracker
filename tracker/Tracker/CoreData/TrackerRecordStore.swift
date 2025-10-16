import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(_ record: TrackerRecord) throws
    func fetchRecords() throws -> [TrackerRecord]
    func fetchRecords(for tracker: Tracker) throws -> [TrackerRecord]
    func deleteRecord(_ record: TrackerRecord) throws
    func countRecords(for tracker: Tracker) throws -> Int
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) throws -> Bool
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addRecord(_ record: TrackerRecord) throws {
        let isCompleted = try isTrackerCompleted(record.trackerId, on: record.date)
        if isCompleted {
            return
        }

        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.id = record.id
        recordEntity.date = record.date
        recordEntity.trackerId = record.trackerId

        Dependencies.shared.coreDataStack.saveContext()
    }

    func fetchRecords() throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let recordEntities = try context.fetch(fetchRequest)
        return recordEntities.compactMap { entity in
            guard let id = entity.id,
                  let date = entity.date else {
                return nil
            }

            let trackerId = entity.value(forKey: "trackerId") as? UUID ?? UUID()

            return TrackerRecord(id: id, trackerId: trackerId, date: date)
        }
    }

    func fetchRecords(for tracker: Tracker) throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordEntity.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker.id as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let recordEntities = try context.fetch(fetchRequest)
        return recordEntities.compactMap { entity in
            guard let id = entity.id,
                  let date = entity.date else {
                return nil
            }

            return TrackerRecord(id: id, trackerId: tracker.id, date: date)
        }
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        let context = Dependencies.shared.coreDataStack.viewContext
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", record.trackerId as CVarArg)

        let allRecords = try context.fetch(fetchRequest)
        let calendar = Calendar.current
        var recordsToDelete: [TrackerRecordEntity] = []

        for recordEntity in allRecords {
            if let recordDate = recordEntity.date,
               calendar.isDate(recordDate, inSameDayAs: record.date) {
                recordsToDelete.append(recordEntity)
            }
        }

        for recordEntity in recordsToDelete {
            context.delete(recordEntity)
        }
        Dependencies.shared.coreDataStack.saveContext()
    }

    func countRecords(for tracker: Tracker) throws -> Int {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", tracker.id as CVarArg)

        let count = try context.count(for: fetchRequest)
        return count
    }

    func isTrackerCompleted(_ trackerId: UUID, on date: Date) throws -> Bool {
        let fetchRequest = TrackerRecordEntity.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)

        let records = try context.fetch(fetchRequest)
        let calendar = Calendar.current

        let completed = records.contains { record in
            guard let recordDate = record.date else { return false }
            return calendar.isDate(recordDate, inSameDayAs: date)
        }
        return completed
    }
}
