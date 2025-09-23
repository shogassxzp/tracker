import UIKit

final class NewTrackerViewController: UIViewController, UIScrollViewDelegate {
    private var selectedSchedule: [Weekday] = []

    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhite
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var emojiCollection = EmojiCollection()
    private var colorCollection = ColorCollection()
    private var selectedEmoji: Character?
    private var selectedColor: UIColor?

    private var scheduleButtonTopConstraint: NSLayoutConstraint!
    private var scheduleButtonCenterYConstraint: NSLayoutConstraint!
    private var categoryButtonTopConstraint: NSLayoutConstraint!
    private var categoryButtonCenterYConstraint: NSLayoutConstraint!

    private var newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackground
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        return textField
    }()

    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Категория"
        config.baseForegroundColor = .ypBlack
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        config.titleAlignment = .leading
        button.configuration = config
        button.contentHorizontalAlignment = .left
        return button
    }()

    private let categorySubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }()

    private let scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Расписание"
        config.baseForegroundColor = .ypBlack
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        config.titleAlignment = .leading
        button.configuration = config
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        return button
    }()

    private let scheduleSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        label.numberOfLines = 2
        return label
    }()

    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Отменить"
        config.baseForegroundColor = .systemRed
        config.background.backgroundColor = .ypWhite
        config.background.strokeColor = .systemRed
        config.background.strokeWidth = 1.0
        config.background.cornerRadius = 16
        button.configuration = config
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    private let categoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()

    private let scheduleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.backgroundColor = .ypWhite
        addSubviewsInScrollView()
        setupView()
        setupTextFieldObserver()
        setupKeyboardDismissal()
        setupCollections()
    }

    private func addSubviewsInScrollView() {
        [newHabitLabel, nameTextField, categoryContainer, separator, scheduleContainer, colorCollection, emojiCollection].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [cancelButton, createButton].forEach {
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
        nameTextField.leftView = leftPaddingView
        nameTextField.delegate = self
        scrollView.delegate = self

        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = false
        contentView.isUserInteractionEnabled = true

        addArrowToContainer(categoryContainer)
        addArrowToContainer(scheduleContainer)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            newHabitLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            newHabitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            categoryContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            categoryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryContainer.heightAnchor.constraint(equalToConstant: 75),

            separator.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            separator.heightAnchor.constraint(equalToConstant: 1),

            scheduleContainer.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 1),
            scheduleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scheduleContainer.heightAnchor.constraint(equalToConstant: 75),

            categoryButton.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),

            categorySubtitleLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 2),
            categorySubtitleLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 16),
            categorySubtitleLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),
            categorySubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: categoryContainer.bottomAnchor, constant: -10),

            scheduleButton.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor),

            scheduleSubtitleLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 2),
            scheduleSubtitleLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
            scheduleSubtitleLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor),
            scheduleSubtitleLabel.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -10),

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

        scheduleButtonTopConstraint = scheduleButton.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 10)
        scheduleButtonCenterYConstraint = scheduleButton.centerYAnchor.constraint(equalTo: scheduleContainer.centerYAnchor)

        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 10)
        categoryButtonCenterYConstraint = categoryButton.centerYAnchor.constraint(equalTo: categoryContainer.centerYAnchor)

        updateScheduleButtonPosition()
        updateCategoryButtonPosition()
    }

    private func setupCollections() {
        colorCollection.onColorSelected = { [weak self] color in
            self?.selectedColor = color
            self?.updateCreateButton()
        }
        emojiCollection.onEmojiSelected = { [weak self] emoji in
            self?.selectedEmoji = emoji
            self?.updateCreateButton()
        }

        NSLayoutConstraint.activate([
            emojiCollection.topAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: 32),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollection.heightAnchor.constraint(equalToConstant: 210),

            colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 32),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            colorCollection.heightAnchor.constraint(equalToConstant: 200),
        ])
    }

    private func addArrowToContainer(_ container: UIView) {
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .gray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
    }

    private func setupTextFieldObserver() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        nameTextField.returnKeyType = .done
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        updateCreateButton()
    }

    private func updateCreateButton() {
        let isNameEmpty = nameTextField.text?.isEmpty ?? true
        let isScheduleEmpty = selectedSchedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil

        let isEnabled = !isNameEmpty && !isScheduleEmpty && isEmojiSelected && isColorSelected

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }

    private func updateScheduleButtonPosition() {
        scheduleButtonTopConstraint.isActive = false
        scheduleButtonCenterYConstraint.isActive = false

        if scheduleSubtitleLabel.isHidden {
            scheduleButtonCenterYConstraint.isActive = true
        } else {
            scheduleButtonTopConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.2) {
            self.scheduleContainer.layoutIfNeeded()
        }
    }

    private func updateCategoryButtonPosition() {
        categoryButtonTopConstraint.isActive = false
        categoryButtonCenterYConstraint.isActive = false

        if categorySubtitleLabel.isHidden {
            categoryButtonCenterYConstraint.isActive = true
        } else {
            categoryButtonTopConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.2) {
            self.categoryContainer.layoutIfNeeded()
        }
    }

    func updateScheduleSubtitle(_ text: String) {
        scheduleSubtitleLabel.text = text
        scheduleSubtitleLabel.isHidden = text.isEmpty
        updateScheduleButtonPosition()
        updateCreateButton()
    }

    func updateCategorySubtitle(_ text: String) {
        categorySubtitleLabel.text = text
        categorySubtitleLabel.isHidden = text.isEmpty
        updateCategoryButtonPosition()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func scheduleTapped() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .popover

        scheduleViewController.onDaysSelected = { [weak self] (selectedDays: [Weekday]) in
            self?.selectedSchedule = selectedDays
            let displayText = Weekday.displayText(for: selectedDays)
            self?.updateScheduleSubtitle(displayText)
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
            color: selectedColor ?? .systemBlue,
            emoji: selectedEmoji ?? " ",
            schedule: selectedSchedule,
            isHabit: true
        )

        TrackerStore.shared.addTracker(tracker, toCategoryTitle: "Домашний уют")

        NotificationCenter.default.post(
            name: NSNotification.Name("TrackerAdded"),
            object: nil
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
        warningLabel.font = .systemFont(ofSize: 12, weight: .regular)
        warningLabel.textAlignment = .center

        view.addSubview(warningLabel)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4),
            warningLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            warningLabel.removeFromSuperview()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateCreateButton()
    }
}
