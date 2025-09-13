import UIKit

final class TrackerViewController: UIViewController {
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
        setupCollection()
    }

    private func addSubview() {
        [habitsCollectionView, newTrackerButton, trackerLabel, searchBar, datePicker].forEach {
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
    
  @objc private func newTracker() {
        let newTrackerViewController = newTrackerViewController()
        newTrackerViewController.modalPresentationStyle = .popover
        present(newTrackerViewController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
    }
}
