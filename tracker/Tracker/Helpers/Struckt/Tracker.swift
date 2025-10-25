import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let isHabit: Bool
    let category: TrackerCategory

    init(
        id: UUID,
        title: String,
        color: UIColor,
        emoji: String,
        schedule: [Weekday],
        isHabit: Bool,
        category: TrackerCategory
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = isHabit
        self.category = category
    }
}

enum Weekday: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday 
    
    var localizedName: String {
        switch self {
        case .monday: return Localizable.monday
        case .tuesday: return Localizable.tuesday
        case .wednesday: return Localizable.wednesday
        case .thursday: return Localizable.thursday
        case .friday: return Localizable.friday
        case .saturday: return Localizable.saturday
        case .sunday: return Localizable.sunday
        }
    }

    var shortName: String {
        switch self {
        case .monday: return Localizable.mon
        case .tuesday: return Localizable.tue
        case .wednesday: return Localizable.wed
        case .thursday: return Localizable.thu
        case .friday: return Localizable.fri
        case .saturday: return Localizable.sat
        case .sunday: return Localizable.sun
        }
    }
}
