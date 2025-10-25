import Foundation

final class StatisticService {
    func calculateStatistics() -> [StatItem] {
        var stats: [StatItem] = []

        do {
            let records = try Dependencies.shared.recordStore.fetchRecords()
            let trackers = try Dependencies.shared.trackerStore.fetchTrackers()

            let bestPeriod = calculateBestPeriod(records: records)
            stats.append(StatItem(title: Localizable.bestPeriod, value: "\(bestPeriod)"))

            let perfectDays = calculatePerfectDays(records: records, trackers: trackers)
            stats.append(StatItem(title: Localizable.perfectDays, value: "\(perfectDays)"))

            let completedTrackers = records.count
            stats.append(StatItem(title: Localizable.completedTrackers, value: "\(completedTrackers)"))

            let average = calculateAverage(records: records)
            stats.append(StatItem(title: Localizable.averageValue, value: "\(average)"))

        } catch {
            stats = [
                StatItem(title: Localizable.bestPeriod, value: "0"),
                StatItem(title: Localizable.perfectDays, value: "0"),
                StatItem(title: Localizable.completedTrackers, value: "0"),
                StatItem(title: Localizable.averageValue, value: "0"),
            ]
        }

        return stats
    }

    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }

        let sortedDates = recordsByDate.keys.sorted()

        var maxStreak = 0
        var currentStreak = 0
        var previousDate: Date?

        for date in sortedDates {
            if let previous = previousDate {
                let daysBetween = calendar.dateComponents([.day], from: previous, to: date).day ?? 0
                if daysBetween == 1 {
                    currentStreak += 1
                } else if daysBetween > 1 {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            previousDate = date
        }

        maxStreak = max(maxStreak, currentStreak)
        return maxStreak
    }

    private func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }

        let habitTrackers = trackers.filter { $0.isHabit }

        var perfectDays = 0

        for (date, dayRecords) in recordsByDate {
            guard let weekday = date.weekday() else { continue }

            let activeHabits = habitTrackers.filter { $0.schedule.contains(weekday) }

            let completedHabitIds = Set(dayRecords.map { $0.trackerId })
            let allHabitsCompleted = activeHabits.allSatisfy { completedHabitIds.contains($0.id) }

            if allHabitsCompleted && !activeHabits.isEmpty {
                perfectDays += 1
            }
        }

        return perfectDays
    }

    private func calculateAverage(records: [TrackerRecord]) -> Int {
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }

        guard !recordsByDate.isEmpty else { return 0 }

        let totalRecords = records.count
        let totalDays = recordsByDate.count

        return totalRecords / totalDays
    }
}
