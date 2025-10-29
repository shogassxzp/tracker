import UIKit

final class StatisticViewController: UIViewController {
    private let statisticService = StatisticService()
    private var statsData: [StatItem] = []

    private lazy var statisticLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.statisticLabel
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyStats)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.emptyStatLabel
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var statisticTableView: StatisticTableView = {
        let tableView = StatisticTableView()
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }

    private func setupUI() {
        [statisticLabel, emptyStateImageView, emptyStateLabel, statisticTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        view.backgroundColor = .ypWhite

        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            statisticTableView.topAnchor.constraint(equalTo: statisticLabel.bottomAnchor, constant: 77),
            statisticTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

        ])
    }

    private func loadStatistics() {
        statsData = statisticService.calculateStatistics()

        let hasStatistics = statsData.contains { stat in
            Int(stat.value) ?? 0 > 0
        }

        if hasStatistics {
            statisticTableView.isHidden = false
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
            statisticTableView.configure(with: statsData)
        } else {
            statisticTableView.isHidden = true
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
        }
    }
}
