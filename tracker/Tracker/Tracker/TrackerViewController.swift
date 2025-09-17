import UIKit

final class TrackerViewController: UIViewController {
    var trackers: [Tracker] = []
    var currentDate = Date()
    
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    private let emptyStateImage = UIImageView()
    
    private let newTrackerButton = UIButton(type: .system)
    private let trackerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    private let habitsCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        addSubview()
        setupView()
        setUpEmptyState()
        setupCollection()
        loadTrackers()
        setupNotifications()
        showEmptyStateIfNeeded()
    }

    private func addSubview() {
        [emptyStateView, habitsCollectionView, newTrackerButton, trackerLabel, searchBar, datePicker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupView() {
        newTrackerButton.setImage(UIImage(resource: .plus), for: .normal)
        newTrackerButton.tintColor = .blackDay
        newTrackerButton.contentHorizontalAlignment = .center
        newTrackerButton.addTarget(self, action: #selector(newTracker), for: .touchUpInside)

        trackerLabel.font = .systemFont(ofSize: 34, weight: .bold)
        trackerLabel.text = "Трекеры"
        trackerLabel.tintColor = .blackDay

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
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
            datePicker.widthAnchor.constraint(equalToConstant: 77),
            datePicker.heightAnchor.constraint(equalToConstant: 34),

            searchBar.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor, constant: -5),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),

        ])
    }

    private func setupCollection() {
        habitsCollectionView.backgroundColor = .whiteDay
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
        
        emptyStateLabel.text = "Что будем отслеживать?"
        emptyStateLabel.textColor = .blackDay
        emptyStateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        
        [emptyStateImage,emptyStateLabel].forEach{
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
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    private func loadTrackers() {
        trackers = TrackerStore.shared.getAllTrackers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.habitsCollectionView.reloadData()
        }
    }
    
    private func loadTrackersForCurrentDate() {
        trackers = TrackerStore.shared.getTrackers(for: currentDate)
        habitsCollectionView.reloadData()
        
        showEmptyStateIfNeeded()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerAdded),
            name: NSNotification.Name("TrackerAdded"),
            object: nil
            
        )
    }

    @objc private func handleTrackerAdded() {
        loadTrackers()
    }
    
    func handleTrackerCompletion(trackerId: String, date: Date, isCompleted: Bool) {
            if isCompleted {
                let record = TrackerRecord(id: UUID().uuidString, trackerId: trackerId, date: date)
                TrackerStore.shared.addRecord(record)
            } else {
                TrackerStore.shared.removeRecord(trackerId: trackerId, date: date)
            }
            habitsCollectionView.reloadData()
        }

    @objc private func newTracker() {
        let newTrackerViewController = NewTrackerViewController()
        newTrackerViewController.modalPresentationStyle = .popover
        present(newTrackerViewController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        loadTrackersForCurrentDate()
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
        if trackers.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
}
