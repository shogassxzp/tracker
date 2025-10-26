import UIKit

final class EditTrackerViewController: NewTrackerViewController {
    private var trackerToEdit: Tracker
    private var completionCount: Int

    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    init(tracker: Tracker, completionCount: Int) {
        trackerToEdit = tracker
        self.completionCount = completionCount
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditMode()
        prefillTrackerData()
    }

    private func setupEditMode() {
        newHabitLabel.text = "Редактирование привычки"

        setupDaysCountLabel()

        createButton.setTitle("Сохранить", for: .normal)
    }

    private func setupDaysCountLabel() {
        daysCountLabel.text = formattedDaysText(completionCount)

        contentView.addSubview(daysCountLabel)
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false

        if let existingConstraint = contentView.constraints.first(where: {
            $0.firstItem as? UIView == nameTextField &&
                $0.firstAttribute == .top
        }) {
            contentView.removeConstraint(existingConstraint)
        }

        NSLayoutConstraint.deactivate([
            nameTextField.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 24),
        ])

        NSLayoutConstraint.activate([
            daysCountLabel.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 24),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 40),

            nameTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
    }

    private func prefillTrackerData() {
        nameTextField.text = trackerToEdit.title
        selectedSchedule = trackerToEdit.schedule
        selectedCategory = trackerToEdit.category
        selectedEmoji = trackerToEdit.emoji.first
        selectedColor = trackerToEdit.color

        updateScheduleSubtitle(Weekday.displayText(for: trackerToEdit.schedule))
        updateCategorySubtitle(trackerToEdit.category.title)

        emojiCollection.selectEmoji(trackerToEdit.emoji)
        colorCollection.selectColor(trackerToEdit.color)

        updateCreateButton()
    }

    override internal func createTracker() {
        guard let title = nameTextField.text,
              !title.isEmpty,
              !selectedSchedule.isEmpty,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji,
              let selectedCategory = selectedCategory
        else {
            return
        }

        let updatedTracker = Tracker(
            id: trackerToEdit.id,
            title: title,
            color: selectedColor,
            emoji: String(selectedEmoji),
            schedule: selectedSchedule,
            isHabit: trackerToEdit.isHabit,
            category: selectedCategory
        )

        do {
            let trackerStore = Dependencies.shared.trackerStore
            try trackerStore.updateTracker(updatedTracker)
            dismiss(animated: true)
        } catch {
            dismiss(animated: true)
        }
    }

    private func formattedDaysText(_ count: Int) -> String {
        let format = NSLocalizedString("days_count", comment: "")
        return String(format: format, count)
    }
}
