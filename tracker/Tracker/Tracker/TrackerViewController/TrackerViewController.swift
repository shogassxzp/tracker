import UIKit

final class TrackerViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    var currentDate = Date()

    private let newTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.tintColor = .ypBlack
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(newTracker), for: .touchUpInside)
        return button
    }()

    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = "Трекеры"
        label.tintColor = .ypBlack
        return label
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
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
        label.text = "Что будем отслеживать?"
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
        showEmptyStateIfNeeded()
        Dependencies.shared.trackerStore.delegate = self
        loadCategories()
        loadCompletedTrackers()
        let context = Dependencies.shared.coreDataStack.viewContext
        let container = Dependencies.shared.coreDataStack.persistentContainer
    }

    private func addSubview() {
        [emptyStateView, habitsCollectionView, newTrackerButton, trackerLabel, searchBar, datePicker].forEach {
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

        ])
    }

    private func setupCollection() {
        habitsCollectionView.backgroundColor = .ypWhite
        habitsCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        habitsCollectionView.dataSource = self
        habitsCollectionView.delegate = self
        habitsCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        habitsCollectionView.allowsSelection = false

        NSLayoutConstraint.activate([
            habitsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
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

    private func loadTrackers() {
        do {
            let trackerStore = Dependencies.shared.trackerStore
            let allTrackers = try trackerStore.fetchTrackers()

            let filteredTrackers = allTrackers.filter { tracker in
                if tracker.isHabit {
                    let schedule = tracker.schedule
                    if let weekday = currentDate.weekday() {
                        let shouldShow = schedule.contains(weekday)
                        return shouldShow
                    }
                    return false
                } else {
                    return true
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
            }.filter { !$0.trackers.isEmpty }

            categories = filteredCategories
        } catch {
            categories = []
        }
        habitsCollectionView.reloadData()
        showEmptyStateIfNeeded()
    }

    private func loadTrackersForCurrentDate() {
        habitsCollectionView.reloadData()

        showEmptyStateIfNeeded()
    }

    private func loadCategories() {
        do {
            let allTrackers = try Dependencies.shared.trackerStore.fetchTrackers()

            let filteredTrackers = allTrackers.filter { tracker in
                if tracker.isHabit {
                    let schedule = tracker.schedule
                    if let weekday = currentDate.weekday() {
                        return schedule.contains(weekday)
                    }
                    return false
                } else {
                    return true
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

        } catch {
            categories = []
        }

        habitsCollectionView.reloadData()
        showEmptyStateIfNeeded()
    }

    private func loadCompletedTrackers() {
        do {
            let records = try Dependencies.shared.recordStore.fetchRecords()
            let calendar = Calendar.current
            let completedToday = records.filter { record in
                calendar.isDate(record.date, inSameDayAs: currentDate)
            }

            completedTrackers = Set(completedToday.map { $0.trackerId })

        } catch {
            completedTrackers = []
        }
    }

    @objc private func handleTrackerAdded() {
        loadCategories()
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
                self.loadCategories()
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
        loadTrackers()
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
        let hasTrackers = categories.contains { !$0.trackers.isEmpty }
        if hasTrackers {
            hideEmptyState()
        } else {
            showEmptyState()
        }
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrackers(_ trackers: [Tracker]) {
        DispatchQueue.main.async {
            self.loadCategories()
        }
    }
}
