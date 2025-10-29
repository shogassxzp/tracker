import UIKit

class NewTrackerViewController: UIViewController, UIScrollViewDelegate {
    var selectedSchedule: [Weekday] = []
    var selectedCategory: TrackerCategory?

    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhite
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var emojiCollection = EmojiCollection()
    var colorCollection = ColorCollection()
    var selectedEmoji: Character?
    var selectedColor: UIColor?

    var scheduleTitleTopConstraint: NSLayoutConstraint!
    var scheduleTitleCenterYConstraint: NSLayoutConstraint!
    var categoryTitleTopConstraint: NSLayoutConstraint!
    var categoryTitleCenterYConstraint: NSLayoutConstraint!

    var newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.newHabit
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Localizable.enterTrackerName
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackground
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        return textField
    }()

    let categoryContainerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        return button
    }()

    let scheduleContainerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        return button
    }()

    let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.category
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    let categorySubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }()

    let scheduleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.schedule
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    let scheduleSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        label.numberOfLines = 2
        return label
    }()

    let createButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localizable.create, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = Localizable.cancel
        config.baseForegroundColor = .systemRed
        config.background.backgroundColor = .ypWhite
        config.background.strokeColor = .systemRed
        config.background.strokeWidth = 1.0
        config.background.cornerRadius = 16
        button.configuration = config
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    let categoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()

    let scheduleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()

    let separator: UIView = {
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

    func addSubviewsInScrollView() {
        [newHabitLabel, nameTextField, categoryContainer, separator, scheduleContainer, colorCollection, emojiCollection].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [categoryContainerButton, categoryTitleLabel, categorySubtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            categoryContainer.addSubview($0)
        }

        [scheduleContainerButton, scheduleTitleLabel, scheduleSubtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scheduleContainer.addSubview($0)
        }
    }

    func setupView() {
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

            categoryContainerButton.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            categoryContainerButton.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),
            categoryContainerButton.topAnchor.constraint(equalTo: categoryContainer.topAnchor),
            categoryContainerButton.bottomAnchor.constraint(equalTo: categoryContainer.bottomAnchor),

            scheduleContainerButton.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor),
            scheduleContainerButton.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor),
            scheduleContainerButton.topAnchor.constraint(equalTo: scheduleContainer.topAnchor),
            scheduleContainerButton.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor),

            categoryTitleLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 16),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor, constant: -40),

            categorySubtitleLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 16),
            categorySubtitleLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor, constant: -40),
            categorySubtitleLabel.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 2),
            categorySubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: categoryContainer.bottomAnchor, constant: -10),

            scheduleTitleLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 16),
            scheduleTitleLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -40),

            scheduleSubtitleLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 16),
            scheduleSubtitleLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -40),
            scheduleSubtitleLabel.topAnchor.constraint(equalTo: scheduleTitleLabel.bottomAnchor, constant: 2),
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

        
        categoryTitleTopConstraint = categoryTitleLabel.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 15)
        categoryTitleCenterYConstraint = categoryTitleLabel.centerYAnchor.constraint(equalTo: categoryContainer.centerYAnchor)

        scheduleTitleTopConstraint = scheduleTitleLabel.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 15)
        scheduleTitleCenterYConstraint = scheduleTitleLabel.centerYAnchor.constraint(equalTo: scheduleContainer.centerYAnchor)

        updateCategoryTitlePosition()
        updateScheduleTitlePosition()
    }

    func setupCollections() {
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

    func addArrowToContainer(_ container: UIView) {
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .gray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
    }

    func updateCategoryTitlePosition() {
        categoryTitleTopConstraint.isActive = false
        categoryTitleCenterYConstraint.isActive = false

        if categorySubtitleLabel.isHidden {
            categoryTitleCenterYConstraint.isActive = true
        } else {
            categoryTitleTopConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.2) {
            self.categoryContainer.layoutIfNeeded()
        }
    }

    func updateScheduleTitlePosition() {
        scheduleTitleTopConstraint.isActive = false
        scheduleTitleCenterYConstraint.isActive = false

        if scheduleSubtitleLabel.isHidden {
            scheduleTitleCenterYConstraint.isActive = true
        } else {
            scheduleTitleTopConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.2) {
            self.scheduleContainer.layoutIfNeeded()
        }
    }

    func setupTextFieldObserver() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        nameTextField.returnKeyType = .done
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func textFieldDidChange() {
        updateCreateButton()
    }

    func updateCreateButton() {
        let isNameEmpty = nameTextField.text?.isEmpty ?? true
        let isScheduleEmpty = selectedSchedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategorySelected = selectedCategory != nil

        let isEnabled = !isNameEmpty && !isScheduleEmpty && isEmojiSelected && isColorSelected && isCategorySelected
        let isActiveColor: UIColor = isEnabled ? .ypWhite : .ypBlack
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        createButton.setTitleColor(isActiveColor, for: .normal)
    }

    func updateScheduleSubtitle(_ text: String) {
        scheduleSubtitleLabel.text = text
        scheduleSubtitleLabel.isHidden = text.isEmpty
        updateScheduleTitlePosition()
        updateCreateButton()
    }

    func updateCategorySubtitle(_ text: String) {
        categorySubtitleLabel.text = text
        categorySubtitleLabel.isHidden = text.isEmpty
        updateCategoryTitlePosition()
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func scheduleTapped() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .popover
        scheduleViewController.selectedDays = selectedSchedule

        scheduleViewController.onDaysSelected = { [weak self] (selectedDays: [Weekday]) in
            self?.selectedSchedule = selectedDays
            let displayText = Weekday.displayText(for: selectedDays)
            self?.updateScheduleSubtitle(displayText)
            self?.updateCreateButton()
        }

        present(scheduleViewController, animated: true)
    }

    @objc func createButtonTapped() {
        createTracker()
    }

    @objc func categoryTapped() {
        let categoriesViewController = CategoriesViewController(
            categoryStore: Dependencies.shared.categoryStore,
            onCategorySelect: { [weak self] selectedCategory in
                self?.selectedCategory = selectedCategory
                self?.updateCategorySubtitle(selectedCategory.title)
                self?.updateCreateButton()
            }
        )
        categoriesViewController.modalPresentationStyle = .popover
        present(categoriesViewController, animated: true)
    }

    func createTracker() {
        guard let title = nameTextField.text,
              !title.isEmpty,
              !selectedSchedule.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji,
              let selectedCategory = selectedCategory
        else {
            return
        }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: selectedColor,
            emoji: String(selectedEmoji),
            schedule: selectedSchedule,
            isHabit: true,
            category: selectedCategory
        )

        do {
            let trackerStore = Dependencies.shared.trackerStore
            try trackerStore.addTracker(tracker, to: selectedCategory)
            dismiss(animated: true)
        } catch {
            dismiss(animated: true)
        }
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
        warningLabel.text = Localizable.characterLimit
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
