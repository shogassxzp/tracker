import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: return Localizable.filterAll
        case .today: return Localizable.filterToday
        case .completed: return Localizable.filterCompleted
        case .uncompleted: return Localizable.filterNotCompleted
        }
    }
}

final class FilterService {
    private let userDefaults = UserDefaults.standard
    private let filterKey = "selected_filter"

    var currentFilter: TrackerFilter {
        get {
            guard let rawValue = userDefaults.string(forKey: filterKey),
                  let filter = TrackerFilter.allCases.first(where: { $0.title == rawValue }) else {
                return .all
            }
            return filter
        }
        set {
            userDefaults.set(newValue.title, forKey: filterKey)
        }
    }

    func resetFilter() {
        userDefaults.removeObject(forKey: filterKey)
    }
}
