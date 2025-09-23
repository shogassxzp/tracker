import Foundation

extension Date {
    func weekday() -> Weekday? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: self)

        switch weekdayNumber {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        case 1: return .sunday
        default: return nil
        }
    }

    func isFuture() -> Bool {
        return self > Date()
    }
}

extension Weekday {
    static func displayText(for days: [Weekday]) -> String {
        if days.count == Weekday.allCases.count {
            return "Каждый день"
        } else {
            return days.map { $0.shortName }.joined(separator: ", ")
        }
    }
}
