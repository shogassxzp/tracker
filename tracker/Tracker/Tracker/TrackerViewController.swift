import UIKit

final class TrackerViewController: UIViewController {
    private var newTrackerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .selectionDarkBlue
        addSubview()
        setupView()
    }

    private func addSubview() {
        [newTrackerButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupView() {
        newTrackerButton.setImage(UIImage(resource: .plus), for: .normal)
        newTrackerButton.tintColor = .blackDay
        newTrackerButton.contentHorizontalAlignment = .right

        NSLayoutConstraint.activate([
            newTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            newTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            newTrackerButton.heightAnchor.constraint(equalToConstant: 42),

        ])
    }
}
