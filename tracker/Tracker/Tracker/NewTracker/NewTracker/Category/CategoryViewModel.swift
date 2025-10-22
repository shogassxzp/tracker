import Foundation

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
    let trackersCount: Int
}

final class CategoriesViewModel {
    private let categoryStore: TrackerCategoryStoreProtocol
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?

    private var trackersCountByCategory: [UUID: Int] = [:]

    var onCategoriesUpdate: (() -> Void)?
    var onCategorySelect: ((TrackerCategory) -> Void)?
    var onError: ((String) -> Void)?

    var numberOfCategories: Int {
        return categories.count
    }

    var isEmpty: Bool {
        return categories.isEmpty
    }

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
    }

    func loadCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()

            updateTrackersCount()

            onCategoriesUpdate?()
        } catch {
            onError?("Не удалось загрузить категории: \(error.localizedDescription)")
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel {
        let category = categories[indexPath.row]
        let isSelected = selectedCategory?.id == category.id
        let trackersCount = trackersCountByCategory[category.id] ?? 0

        return CategoryCellViewModel(
            title: category.title,
            isSelected: isSelected,
            trackersCount: trackersCount
        )
    }

    func selectCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category
        onCategorySelect?(category)
        onCategoriesUpdate?()
    }

    func addNewCategory(_ title: String) {
        let newCategory = TrackerCategory(id: UUID(), title: title)

        do {
            try categoryStore.addCategory(newCategory)
            categories.append(newCategory)
            trackersCountByCategory[newCategory.id] = 0
            onCategoriesUpdate?()
        } catch {
            onError?("Не удалось создать категорию: \(error.localizedDescription)")
        }
    }

    func deleteCategory(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row]

        do {
            try categoryStore.deleteCategory(categoryToDelete)
            categories.remove(at: indexPath.row)
            trackersCountByCategory.removeValue(forKey: categoryToDelete.id)

            if selectedCategory?.id == categoryToDelete.id {
                selectedCategory = nil
            }

            onCategoriesUpdate?()
        } catch {
            onError?("Не удалось удалить категорию: \(error.localizedDescription)")
        }
    }

    func getSelectedCategory() -> TrackerCategory? {
        return selectedCategory
    }

    func setSelectedCategory(_ category: TrackerCategory?) {
        selectedCategory = category
        onCategoriesUpdate?()
    }

    private func updateTrackersCount() {
        for category in categories {
            trackersCountByCategory[category.id] = 0
        }
    }
}
