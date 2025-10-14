import Foundation

struct TrackerCategory {
    let id: UUID
    let title: String
    let trackers: [Tracker]
    
    init(id: UUID, title: String, trackers: [Tracker] = []) {
        self.id = id
        self.title = title
        self.trackers = trackers
    }
}
