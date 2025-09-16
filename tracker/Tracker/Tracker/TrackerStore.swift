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
        return trackers
    }
}
