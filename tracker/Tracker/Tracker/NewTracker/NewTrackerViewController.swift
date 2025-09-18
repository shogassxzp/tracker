import UIKit

final class NewTrackerViewController: UIViewController {
    private var selectedSchedule: [Weekday] = []

    private let newHabitLabel = UILabel()
    private let nameTextField = UITextField()
    private let categoryButton = UIButton()
    private let categorySubtitleLabel = UILabel()
    private let scheduleButton = UIButton()
    private let scheduleSubtitleLabel = UILabel()
    private let createButton = UIButton()
    private let cancelButton = UIButton()
    private let categoryContainer = UIView()
    private let scheduleContainer = UIView()
    private let separator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        addSubviews()
        setupView()
    }

    private func addSubviews() {
        [newHabitLabel, nameTextField, createButton, cancelButton, categoryContainer, separator, scheduleContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [categoryButton, categorySubtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            categoryContainer.addSubview($0)
        }

        [scheduleButton, scheduleSubtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scheduleContainer.addSubview($0)
        }
    }

    private func setupView() {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))

        newHabitLabel.text = "Новая привычка"
        newHabitLabel.font = .systemFont(ofSize: 16, weight: .medium)
        newHabitLabel.textAlignment = .center

        nameTextField.placeholder = "Введите название трекера"
        nameTextField.leftView = leftPaddingView
        nameTextField.leftViewMode = .always
        nameTextField.textAlignment = .left
        nameTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameTextField.backgroundColor = .backgroundDay
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.cornerRadius = 16
        nameTextField.delegate = self
        

        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.setTitleColor(.blackDay, for: .normal)
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.titleEdgeInsets = UIEdgeInsets(top: 30, left: 16, bottom: 0, right: 0)

        categorySubtitleLabel.textColor = .ypGray
        categorySubtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        categorySubtitleLabel.isHidden = true

        scheduleButton.setTitle("Расписание", for: .normal)
        scheduleButton.setTitleColor(.blackDay, for: .normal)
        scheduleButton.contentHorizontalAlignment = .left
        scheduleButton.titleEdgeInsets = UIEdgeInsets(top: 30, left: 16, bottom: 0, right: 0)
        scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)

        scheduleSubtitleLabel.textColor = .ypGray
        scheduleSubtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        scheduleSubtitleLabel.isHidden = true

        addArrowToButton(categoryButton)
        addArrowToButton(scheduleButton)

        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = .whiteDay
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.whiteDay, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)

        categoryContainer.backgroundColor = .backgroundDay
        scheduleContainer.backgroundColor = .backgroundDay
        categoryContainer.layer.cornerRadius = 16
        categoryContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scheduleContainer.layer.cornerRadius = 16
        scheduleContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        categoryContainer.clipsToBounds = true
        scheduleContainer.clipsToBounds = true

        separator.backgroundColor = .separator

        NSLayoutConstraint.activate([
            newHabitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            categoryContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            categoryContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryContainer.heightAnchor.constraint(equalToConstant: 75),

            separator.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            separator.heightAnchor.constraint(equalToConstant: 1),

            scheduleContainer.topAnchor.constraint(equalTo: separator.bottomAnchor,constant: 1),
            scheduleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleContainer.heightAnchor.constraint(equalToConstant: 75),

            categoryButton.topAnchor.constraint(equalTo: categoryContainer.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 44),

            categorySubtitleLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 2),
            categorySubtitleLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 16),
            categorySubtitleLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor, constant: -16),
            categorySubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: categoryContainer.bottomAnchor, constant: -10),

            scheduleButton.topAnchor.constraint(equalTo: scheduleContainer.topAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 44),

            scheduleSubtitleLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 2),
            scheduleSubtitleLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 16),
            scheduleSubtitleLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -16),
            scheduleSubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: scheduleContainer.bottomAnchor, constant: -10),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),

            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func addArrowToButton(_ button: UIButton) {
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .gray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.topAnchor.constraint(equalTo: button.centerYAnchor,constant: 8),
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupTextFieldObserver() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidChange),
            name: UITextField.textDidChangeNotification,
            object: nameTextField
        )
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButton()
    }
    
    private func updateCreateButton() {
        let isNameEmpty = nameTextField.text?.isEmpty ?? true
        let isScheduleEmpty = selectedSchedule.isEmpty
        
        let isEnabled = !isNameEmpty && !isScheduleEmpty
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .blackDay : .ypGray
    }

    func updateScheduleSubtitle(_ text: String) {
        scheduleSubtitleLabel.text = text
        scheduleSubtitleLabel.isHidden = text.isEmpty
        updateCreateButton()
    }

    func updateCategorySubtitle(_ text: String) {
        categorySubtitleLabel.text = text
        categorySubtitleLabel.isHidden = text.isEmpty
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func scheduleTapped() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .popover

        scheduleViewController.onDaysSelected = { [weak self] (selectedDays: [Weekday]) in
            self?.selectedSchedule = selectedDays
            let shortDays = selectedDays.map { $0.shortName }
            self?.updateScheduleSubtitle(shortDays.joined(separator: ", "))
        }

        present(scheduleViewController, animated: true)
    }

    private func createTracker() {
        guard let title = nameTextField.text, !title.isEmpty else {
            showAlert(message: "Введите название трекера")
            return
        }

        guard !selectedSchedule.isEmpty else {
            showAlert(message: "Выберите дни недели")
            return
        }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .selectionDarkBlue,
            emoji: "😇",
            schedule: selectedSchedule,
            isHabit: true
        )

        TrackerStore.shared.addTracker(tracker, toCategoryTitle: "Домашний уют")

        NotificationCenter.default.post(name: NSNotification.Name("TrackerAdded"),
                                        object: nil,
                                        userInfo: ["tracker": tracker]
        )

        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        createTracker()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 38 {
            showCharacterLimitWarning()
            return false
        }
        return true
    }
    
    private func showCharacterLimitWarning() {
        let warningLabel = UILabel()
        warningLabel.text = "Ограничение 38 символов"
        warningLabel.textColor = .systemRed
        warningLabel.font = .systemFont(ofSize: 17, weight: .regular)
        warningLabel.textAlignment = .center
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4),
            warningLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            warningLabel.removeFromSuperview()
        }
    }
}
