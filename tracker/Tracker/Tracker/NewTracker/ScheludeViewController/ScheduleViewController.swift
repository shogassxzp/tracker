import UIKit

final class ScheduleViewController: UIViewController {
    var onDaysSelected: (([Weekday]) -> Void)?
    var selectedDays: [Weekday] = []

    private let weekdays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private let scheludeLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private var switches: [UISwitch] = []
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = .ypBackground
        stackView.layer.cornerRadius = 16
        stackView.clipsToBounds = true
        return stackView
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTouchUp), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDays()
        setupSwitchState()
    }

    private func setupView() {
        [scheludeLabel, stackView, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        view.backgroundColor = .ypWhite

        NSLayoutConstraint.activate([
            scheludeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheludeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: scheludeLabel.bottomAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -50),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func saveButtonTouchUp() {
        let selectedDays = getSelectedDays()
        onDaysSelected?(getSelectedDays())
        dismiss(animated: true)
    }

    private func setupDays() {
        for (index, day) in weekdays.enumerated() {
            let dayView = createDayView(for: day.rawValue, isLast: index == weekdays.count - 1)
            stackView.addArrangedSubview(dayView)
        }
    }

    private func createDayView(for day: String, isLast: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = .ypBackground
        container.heightAnchor.constraint(equalToConstant: 75).isActive = true

        let label = UILabel()
        label.text = day
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17, weight: .regular)

        let switchControl = UISwitch()
        switchControl.onTintColor = .selectionBlue
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        switches.append(switchControl)

        [label, switchControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            switchControl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        if !isLast {
            let separator = createSeparator()
            container.addSubview(separator)

            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1),
            ])
        }

        return container
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }

    private func setupSwitchState() {
        for (index, weekday) in weekdays.enumerated() {
            if index < switches.count {
                let switchControl = switches[index]
                switchControl.isOn = selectedDays.contains(weekday)
            }
        }
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        guard let index = switches.firstIndex(of: sender) else { return }
        let day = weekdays[index]
    }

    func getSelectedDays() -> [Weekday] {
        return switches.enumerated().compactMap { index, switchControl in
            switchControl.isOn ? weekdays[index] : nil
        }
    }
}
