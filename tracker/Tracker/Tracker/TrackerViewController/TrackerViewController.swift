import UIKit

final class TrackerViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    var currentDate = Date()

    var visibleCategories: [TrackerCategory] = []
    private var isSearching = false

    private let filterService = FilterService()
    private var currentFilter: TrackerFilter = .all

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.filterLabel, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)

        return button
    }()

    private let newTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .plus).withTintColor(.ypBlack), for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(newTracker), for: .touchUpInside)
        return button
    }()

    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = Localizable.trackers
        label.tintColor = .ypBlack
        return label
    }()

    private let searchBar: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.placeholder = Localizable.search
        searchBar.clearButtonMode = .whileEditing
        searchBar.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        return searchBar
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()

    private let habitsCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    private let emptyStateView = UIView()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.emptyTracker
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let emptyStateImage = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addSubview()
        setupView()
        setUpEmptyState()
        setupCollection()

        currentFilter = filterService.currentFilter
        applyCurrentFilter()

        showEmptyStateIfNeeded()
        Dependencies.shared.trackerStore.delegate = self
        loadCompletedTrackers()
    }

    private func addSubview() {
        [emptyStateView, habitsCollectionView, newTrackerButton, trackerLabel, searchBar, datePicker, filtersButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupView() {
        datePicker.date = currentDate
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        NSLayoutConstraint.activate([
            newTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            newTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            newTrackerButton.heightAnchor.constraint(equalToConstant: 42),

            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.topAnchor.constraint(equalTo: newTrackerButton.bottomAnchor, constant: 1),

            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: newTrackerButton.topAnchor),

            searchBar.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor, constant: -5),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36),

            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
        ])
    }

    private func setupCollection() {
        habitsCollectionView.backgroundColor = .ypWhite
        habitsCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        habitsCollectionView.dataSource = self
        habitsCollectionView.delegate = self
        habitsCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        habitsCollectionView.allowsSelection = false

        habitsCollectionView.alwaysBounceVertical = true

        NSLayoutConstraint.activate([
            habitsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            habitsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            habitsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            habitsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func setUpEmptyState() {
        emptyStateView.isHidden = true

        emptyStateImage.image = UIImage(resource: .collectionPlaceholder)
        emptyStateImage.tintColor = .ypGray

        [emptyStateImage, emptyStateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            emptyStateView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 10),
            emptyStateImage.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImage.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 10),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
        ])
    }

    @objc private func filtersButtonTapped() {
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.delegate = self
        filtersVC.modalPresentationStyle = .popover

        present(filtersVC, animated: true)
    }

    private func applyCurrentFilter() {
        loadCompletedTrackers()

        do {
            let allTrackers = try Dependencies.shared.trackerStore.fetchTrackers()

            var filteredTrackers: [Tracker]

            switch currentFilter {
            case .all:

                filteredTrackers = allTrackers

            case .today:

                let today = Date()
                filteredTrackers = allTrackers.filter { tracker in
                    if tracker.isHabit {
                        if let weekday = today.weekday() {
                            return tracker.schedule.contains(weekday)
                        }
                        return false
                    } else {
                        return true
                    }
                }

            case .completed:

                filteredTrackers = allTrackers.filter { tracker in

                    let isActiveOnSelectedDate: Bool
                    if tracker.isHabit {
                        if let weekday = currentDate.weekday() {
                            isActiveOnSelectedDate = tracker.schedule.contains(weekday)
                        } else {
                            isActiveOnSelectedDate = false
                        }
                    } else {
                        isActiveOnSelectedDate = true
                    }

                    let isCompleted = completedTrackers.contains(tracker.id)

                    return isActiveOnSelectedDate && isCompleted
                }

            case .uncompleted:

                filteredTrackers = allTrackers.filter { tracker in

                    let isActiveOnSelectedDate: Bool
                    if tracker.isHabit {
                        if let weekday = currentDate.weekday() {
                            isActiveOnSelectedDate = tracker.schedule.contains(weekday)
                        } else {
                            isActiveOnSelectedDate = false
                        }
                    } else {
                        isActiveOnSelectedDate = true
                    }

                    let isUncompleted = !completedTrackers.contains(tracker.id)

                    return isActiveOnSelectedDate && isUncompleted
                }
            }

            let groupedTrackers = Dictionary(grouping: filteredTrackers) { $0.category.title }
            let filteredCategories = groupedTrackers.map { title, trackers in
                let originalCategory = allTrackers.first { $0.category.title == title }?.category
                return TrackerCategory(
                    id: originalCategory?.id ?? UUID(),
                    title: title,
                    trackers: trackers
                )
            }.sorted { $0.title < $1.title }

            categories = filteredCategories
            visibleCategories = filteredCategories

        } catch {
            categories = []
            visibleCategories = []
        }

        habitsCollectionView.reloadData()
        showEmptyStateIfNeeded()
    }

    @objc private func searchTextChanged(_ searchField: UISearchTextField) {
        guard let searchText = searchField.text?.lowercased() else { return }

        if searchText.isEmpty {
            isSearching = false
            applyCurrentFilter()
        } else {
            isSearching = true
            filterTrackers(with: searchText)
        }
    }

    private func filterTrackers(with searchText: String) {
        do {
            let allTrackers = try Dependencies.shared.trackerStore.fetchTrackers()

            var baseTrackers: [Tracker]

            switch currentFilter {
            case .all:
                baseTrackers = allTrackers
            case .today:
                let today = Date()
                baseTrackers = allTrackers.filter { tracker in
                    if tracker.isHabit {
                        if let weekday = today.weekday() {
                            return tracker.schedule.contains(weekday)
                        }
                        return false
                    } else {
                        return true
                    }
                }
            case .completed:
                baseTrackers = allTrackers.filter { tracker in
                    let isActiveOnSelectedDate: Bool
                    if tracker.isHabit {
                        if let weekday = currentDate.weekday() {
                            isActiveOnSelectedDate = tracker.schedule.contains(weekday)
                        } else {
                            isActiveOnSelectedDate = false
                        }
                    } else {
                        isActiveOnSelectedDate = true
                    }
                    return isActiveOnSelectedDate && completedTrackers.contains(tracker.id)
                }
            case .uncompleted:
                baseTrackers = allTrackers.filter { tracker in
                    let isActiveOnSelectedDate: Bool
                    if tracker.isHabit {
                        if let weekday = currentDate.weekday() {
                            isActiveOnSelectedDate = tracker.schedule.contains(weekday)
                        } else {
                            isActiveOnSelectedDate = false
                        }
                    } else {
                        isActiveOnSelectedDate = true
                    }
                    return isActiveOnSelectedDate && !completedTrackers.contains(tracker.id)
                }
            }

            let searchedTrackers = baseTrackers.filter { tracker in
                tracker.title.lowercased().contains(searchText)
            }

            let groupedTrackers = Dictionary(grouping: searchedTrackers) { $0.category.title }
            visibleCategories = groupedTrackers.map { title, trackers in
                let originalCategory = allTrackers.first { $0.category.title == title }?.category
                return TrackerCategory(
                    id: originalCategory?.id ?? UUID(),
                    title: title,
                    trackers: trackers
                )
            }.sorted { $0.title < $1.title }

        } catch {
            visibleCategories = []
        }

        habitsCollectionView.reloadData()
        updateEmptyStateForSearch()
    }

    private func loadTrackers() {
        applyCurrentFilter()
    }

    private func loadTrackersForCurrentDate() {
        habitsCollectionView.reloadData()
        showEmptyStateIfNeeded()
    }

    func loadCategories() {
        applyCurrentFilter()
    }

    private func loadCompletedTrackers() {
        do {
            let records = try Dependencies.shared.recordStore.fetchRecords()
            let calendar = Calendar.current

            let targetDate = currentFilter == .today ? Date() : currentDate

            let completedOnTargetDate = records.filter { record in
                calendar.isDate(record.date, inSameDayAs: targetDate)
            }

            completedTrackers = Set(completedOnTargetDate.map { $0.trackerId })

        } catch {
            completedTrackers = []
        }
    }

    @objc private func handleTrackerAdded() {
        applyCurrentFilter()
    }

    func handleTrackerCompletion(trackerId: UUID, date: Date, isCompleted: Bool) {
        do {
            let recordStore = Dependencies.shared.recordStore

            if isCompleted {
                let record = TrackerRecord(
                    id: UUID(),
                    trackerId: trackerId,
                    date: date
                )
                try recordStore.addRecord(record)
                completedTrackers.insert(trackerId)
            } else {
                let records = try recordStore.fetchRecords()
                let calendar = Calendar.current

                if let recordToDelete = records.first(where: {
                    $0.trackerId == trackerId && calendar.isDate($0.date, inSameDayAs: date)
                }) {
                    try recordStore.deleteRecord(recordToDelete)
                    completedTrackers.remove(trackerId)
                } else { return }
            }

            DispatchQueue.main.async {
                self.applyCurrentFilter()
            }

        } catch {
            return
        }
    }

    private func updateCellForTracker(_ trackerId: UUID) {
        for (sectionIndex, category) in categories.enumerated() {
            for (itemIndex, tracker) in category.trackers.enumerated() {
                if tracker.id == trackerId {
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    habitsCollectionView.reloadItems(at: [indexPath])
                    return
                }
            }
        }
    }

    @objc private func newTracker() {
        let newTrackerViewController = NewTrackerViewController()
        newTrackerViewController.modalPresentationStyle = .popover
        present(newTrackerViewController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date

        loadCompletedTrackers()

        if let searchText = searchBar.text, !searchText.isEmpty, isSearching {
            filterTrackers(with: searchText)
        } else {
            applyCurrentFilter()
        }
    }

    private func showEmptyState() {
        emptyStateView.isHidden = false
        habitsCollectionView.isHidden = true
    }

    private func hideEmptyState() {
        emptyStateView.isHidden = true
        habitsCollectionView.isHidden = false
    }

    private func showEmptyStateIfNeeded() {
        let hasTrackers = visibleCategories.contains { !$0.trackers.isEmpty }

        if hasTrackers {
            hideEmptyState()
        } else {
            showEmptyState()
        }

        updateEmptyStateForSearch()
    }

    private func updateEmptyStateForSearch() {
        let hasVisibleTrackers = visibleCategories.contains { !$0.trackers.isEmpty }

        if isSearching {
            emptyStateLabel.text = Localizable.noTrackersFound
            emptyStateImage.image = UIImage(resource: .findError)
        } else {
            emptyStateLabel.text = Localizable.emptyTracker
            emptyStateImage.image = UIImage(resource: .collectionPlaceholder)
        }

        emptyStateView.isHidden = hasVisibleTrackers
        habitsCollectionView.isHidden = !hasVisibleTrackers
    }
}

extension TrackerViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        filterService.currentFilter = filter

        switch filter {
        case .today:

            currentDate = Date()
            datePicker.date = currentDate
        case .all:

            break
        case .completed, .uncompleted:

            break
        }

        loadCompletedTrackers()
        applyCurrentFilter()
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrackers(_ trackers: [Tracker]) {
        DispatchQueue.main.async {
            self.loadCompletedTrackers()
            self.applyCurrentFilter()
        }
    }
}
