import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(_ record: TrackerRecord) throws
    func fetchRecords() throws -> [TrackerRecord]
    func fetchRecords(for tracker: Tracker) throws -> [TrackerRecord]
    func deleteRecord(_ record: TrackerRecord) throws
    func countRecords(for tracker: Tracker) throws -> Int
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addRecord(_ record: TrackerRecord) throws {
        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.id = record.id
        recordEntity.date = record.date

        recordEntity.setValue(record.trackerId as NSSecureCoding?, forKey: "tracker")

        try context.save()
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

            let trackerId = entity.value(forKey: "tracker") as? UUID ?? UUID()

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
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)

        if let recordEntity = try context.fetch(fetchRequest).first {
            context.delete(recordEntity)
            try context.save()
        }
    }

    func countRecords(for tracker: Tracker) throws -> Int {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker.id as CVarArg)

        return try context.count(for: fetchRequest)
    }
}
