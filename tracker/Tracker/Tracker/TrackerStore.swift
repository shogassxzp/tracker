import UIKit

final class TrackerStore {
    static let shared = TrackerStore()

    private init() { }

    private var trackers: [Tracker] = []

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
}
