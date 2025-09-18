import UIKit

final class TrackerStore {
    static let shared = TrackerStore()

    private init() { }
    
    private var categories: [TrackerCategory] = []
    private var trackerRecords: [TrackerRecord] = []

    func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            var updatedCategories = categories
            let category = updatedCategories[index]
            let updatedTrackers = category.trackers + [tracker]
            let updatedCategory = TrackerCategory(
                id: category.id,
                title: category.title,
                trackers: updatedTrackers
            )
            updatedCategories[index] = updatedCategory
            categories = updatedCategories
        } else {
            let newCategory = TrackerCategory(
                id: UUID().uuidString,
                title: categoryTitle,
                trackers: [tracker]
            )
            categories.append(newCategory)
        }
    }
    
    func getTrackersCount() -> Int {
        return categories.flatMap { $0.trackers }.count
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    

    func setCategories(_ newCategories: [TrackerCategory]) {
        categories = newCategories
    }

    func getCategories() -> [TrackerCategory] {
            return categories
        }
    
    func getAllRecords() -> [TrackerRecord] {
            return trackerRecords
        }

    func addRecord(_ record: TrackerRecord) {
        trackerRecords.append(record)
    }

    func removeRecord(trackerId: String, date: Date) {
        trackerRecords.removeAll { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func isCompleted(trackerId: String, date: Date) -> Bool {
        return trackerRecords.contains {
            $0.trackerId == trackerId &&
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func completionCount(trackerId: String) -> Int {
        return trackerRecords.filter { $0.trackerId == trackerId }.count
    }
    
    func clearAllData() {
        categories = []
        trackerRecords = []
    }
}
