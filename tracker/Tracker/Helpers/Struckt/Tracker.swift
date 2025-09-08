import Foundation

enum Weekday: String, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednsday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
struct Tracker {
    let id: String
    let name: String
    let color: String // hex-color
    let emoji: Character
    let schelude: [Weekday]?
}




