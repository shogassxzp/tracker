import UIKit

final class TrackerStore {
    static let shared = TrackerStore()

    private init() { }

    private var trackers: [Tracker] = []
    private var trackerRecords: [TrackerRecord] = []

    func addTracker(_ tracker: Tracker) {
        trackers.append(tracker)
    }

    func getAllTrackers() -> [Tracker] {
        return trackers
    }

    func getTrackers(for date: Date) -> [Tracker] {
        let weekday = date.weekday()

        return trackers.filter { tracker in
            guard tracker.isHabit else { return true }

            if let schedule = tracker.schedule, let weekday = weekday {
                return schedule.contains(weekday)
            }

            return false
        }
    }

    func addRecord(_ record: TrackerRecord) {
        trackerRecords.append(record)
    }

    func removeRecord(trackerId: String, date: Date) {
        trackerRecords.removeAll { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func isCompleted(trackerId: String, date: Date) -> Bool {
        return trackerRecords.contains{ $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func completionCount(trackerId: String) -> Int {
        return trackerRecords.filter {$0.trackerId == trackerId }.count
    }
}
