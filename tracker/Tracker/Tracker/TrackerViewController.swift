import UIKit

final class TrackerViewController: UIViewController {
    private var newTrackerButton = UIButton(type: .system)
    private var trackerLabel = UILabel()
    private var searchBar = UISearchBar()
    private var datePickerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        addSubview()
        setupView()
    }

    private func addSubview() {
        [newTrackerButton, trackerLabel, searchBar, datePickerButton].forEach {
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
        
        datePickerButton.backgroundColor = .systemGray5
        datePickerButton.setTitle("\(Date.now.formattedDate())", for: .normal)
        datePickerButton.tintColor = .blackDay
        datePickerButton.layer.masksToBounds = true
        datePickerButton.layer.cornerRadius = 8
        datePickerButton.titleLabel?.font = .systemFont(ofSize: 17,weight: .regular)
        datePickerButton.contentMode = .center
        

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal

        NSLayoutConstraint.activate([
            newTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            newTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            newTrackerButton.heightAnchor.constraint(equalToConstant: 42),

            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.topAnchor.constraint(equalTo: newTrackerButton.bottomAnchor, constant: 1),
            
            datePickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePickerButton.topAnchor.constraint(equalTo: newTrackerButton.topAnchor),
            datePickerButton.widthAnchor.constraint(equalToConstant: 77),
            datePickerButton.heightAnchor.constraint(equalToConstant: 34),

            searchBar.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor, constant: -5),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),

        ])
    }
}
