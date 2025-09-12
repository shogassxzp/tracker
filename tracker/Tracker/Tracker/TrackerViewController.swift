import UIKit

final class TrackerViewController: UIViewController {
    private let newTrackerButton = UIButton(type: .system)
    private let trackerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    private let habits = UICollectionView(
        frame: CGRect(origin: CGPoint(x: 0, y: 0),
        size: CGSize(width: 300, height: 600)),
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
        [habits, newTrackerButton, trackerLabel, searchBar,datePicker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupView() {
        newTrackerButton.setImage(UIImage(resource: .plus), for: .normal)
        newTrackerButton.tintColor = .blackDay
        newTrackerButton.contentHorizontalAlignment = .center

        trackerLabel.font = .systemFont(ofSize: 34, weight: .bold)
        trackerLabel.text = "Трекеры"
        trackerLabel.tintColor = .blackDay

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal

        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
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

            habits.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            habits.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            habits.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            habits.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        ])
    }

    private func setupCollection() {
        habits.backgroundColor = .blackDay
        habits.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.inedtifier)
        habits.dataSource = self
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
    }
}
