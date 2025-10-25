import Foundation

enum Localizable {
    static let trackers = NSLocalizedString("trackers", comment: "Main screen title")
    static let search = NSLocalizedString("search", comment: "Search placeholder")
    static let cancel = NSLocalizedString("cancel", comment: "Cancel button")
    static let create = NSLocalizedString("create", comment: "Create button")
    static let done = NSLocalizedString("done", comment: "Done button")
    static let delete = NSLocalizedString("delete", comment: "Delete action")
    static let edit = NSLocalizedString("edit", comment: "Edit action")
    static let save = NSLocalizedString("save", comment: "Save button")
    static let error = NSLocalizedString("error", comment: "Error title")
    static let emptyTracker = NSLocalizedString("whatTrack", comment: "whatTrack")

    // Tracker screens
    static let newHabit = NSLocalizedString("new_habit", comment: "New habit title")
    static let irregularEvent = NSLocalizedString("irregular_event", comment: "Irregular event title")
    static let enterTrackerName = NSLocalizedString("enter_tracker_name", comment: "Tracker name placeholder")
    static let category = NSLocalizedString("category", comment: "Category button")
    static let schedule = NSLocalizedString("schedule", comment: "Schedule button")
    static let emoji = NSLocalizedString("emoji", comment: "Emoji section")
    static let color = NSLocalizedString("color", comment: "Color section")

    // Category screens
    static let categories = NSLocalizedString("categories", comment: "Categories title")
    static let newCategory = NSLocalizedString("new_category", comment: "New category title")
    static let enterCategoryName = NSLocalizedString("enter_category_name", comment: "Category name placeholder")
    static let habitsCanBeGrouped = NSLocalizedString("habits_can_be_grouped", comment: "Empty state message")
    static let addCategory = NSLocalizedString("add_category", comment: "Add category button")

    // Schedule
    static let monday = NSLocalizedString("monday", comment: "Monday")
    static let tuesday = NSLocalizedString("tuesday", comment: "Tuesday")
    static let wednesday = NSLocalizedString("wednesday", comment: "Wednesday")
    static let thursday = NSLocalizedString("thursday", comment: "Thursday")
    static let friday = NSLocalizedString("friday", comment: "Friday")
    static let saturday = NSLocalizedString("saturday", comment: "Saturday")
    static let sunday = NSLocalizedString("sunday", comment: "Sunday")

    static let mon = NSLocalizedString("mon", comment: "Monday short")
    static let tue = NSLocalizedString("tue", comment: "Tuesday short")
    static let wed = NSLocalizedString("wed", comment: "Wednesday short")
    static let thu = NSLocalizedString("thu", comment: "Thursday short")
    static let fri = NSLocalizedString("fri", comment: "Friday short")
    static let sat = NSLocalizedString("sat", comment: "Saturday short")
    static let sun = NSLocalizedString("sun", comment: "Sunday short")

    // Onboarding
    static let trackOnlyWhatYouWant = NSLocalizedString("track_only_what_you_want", comment: "First onboarding screen")
    static let evenIfNotWaterAndYoga = NSLocalizedString("even_if_not_water_and_yoga", comment: "Second onboarding screen")
    static let thatIsTechnology = NSLocalizedString("that_is_technology", comment: "Onboarding button")

    // Days count
    static func daysCount(_ count: Int) -> String {
        let format = NSLocalizedString("days_count", comment: "Days count with pluralization")
        return String.localizedStringWithFormat(format, count)
    }

    // Errors
    static let failedToCreateTracker = NSLocalizedString("failed_to_create_tracker", comment: "Tracker creation error")
    static let failedToLoadCategories = NSLocalizedString("failed_to_load_categories", comment: "Categories loading error")
    static let failedToCreateCategory = NSLocalizedString("failed_to_create_category", comment: "Category creation error")
    static let failedToDeleteCategory = NSLocalizedString("failed_to_delete_category", comment: "Category deletion error")
    static let characterLimit = NSLocalizedString("character_limit", comment: "Character limit warning")

    // Delete confirmations
    static let deleteCategoryConfirmation = NSLocalizedString("delete_category_confirmation", comment: "Delete confirmation title")
    // Date
    static let everyDay = NSLocalizedString("every_day", comment: "Every day in schedule")
    static let everyDayShort = NSLocalizedString("every_day_short", comment: "Every day short version")
    
    static let imortant = NSLocalizedString("important", comment: "important")
    static let statistic = NSLocalizedString("statistic", comment: "Statistic")
    
    static let noTrackersFound = NSLocalizedString("no_trackers_found", comment: "noTrackersFound")
    static let bestPeriod = NSLocalizedString("best_period", comment: "Best period stats")
    static let emptyStatLabel = NSLocalizedString("empty_stat", comment: "Empty statistic label")
    static let perfectDays = NSLocalizedString("perfect_days", comment: "Perfect Days Stats")
    static let completedTrackers = NSLocalizedString("completed_trackers", comment: "Completed trackers stats")
    static let averageValue = NSLocalizedString("average_value", comment: "average value stats")
    static let statisticLabel = NSLocalizedString("statisticLabel", comment: "statistic label")
}
