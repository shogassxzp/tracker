import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "habit"

    private let contentContainer = UIView()
    private var trackerId: String?
    private var currentDate: Date?

    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let emojiContainer = UIView()

    private let footerContainer = UIView()
    private let completionButton = UIButton()
    private let daysLabel = UILabel()
    
    private var onCompletion: ((String, Date, Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        [contentContainer, titleLabel, emojiContainer, emojiLabel, footerContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        [completionButton,daysLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            footerContainer.addSubview($0)
        }
        
        contentContainer.layer.masksToBounds = true
        contentContainer.layer.cornerRadius = 16
        footerContainer.layer.masksToBounds = true
        completionButton.layer.masksToBounds = true
        completionButton.layer.cornerRadius = 17
        emojiContainer.layer.masksToBounds = true
        emojiContainer.layer.cornerRadius = 12
        emojiContainer.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        
        completionButton.addTarget(self, action: #selector(completionButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.heightAnchor.constraint(equalToConstant: 90),

            titleLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: 12),
            
            emojiContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            emojiContainer.topAnchor.constraint(equalTo: contentContainer.topAnchor,constant: 12),
            emojiContainer.heightAnchor.constraint(equalToConstant: 24),
            emojiContainer.widthAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),

            footerContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            footerContainer.heightAnchor.constraint(equalToConstant: 50),
            footerContainer.topAnchor.constraint(equalTo: contentContainer.bottomAnchor),

            daysLabel.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor,constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: footerContainer.centerYAnchor),

            completionButton.widthAnchor.constraint(equalToConstant: 34),
            completionButton.heightAnchor.constraint(equalToConstant: 34),
            completionButton.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor),
            completionButton.centerYAnchor.constraint(equalTo: footerContainer.centerYAnchor),

        ])
    }

    func configure(with tracker: Tracker,
                   date: Date,
                   isCompleted: Bool,
                   completionCount: Int,
                   onCompletion: ((String, Date, Bool) -> Void)? = nil
    ) {
        self.trackerId = tracker.id.uuidString
        self.currentDate = date
        self.onCompletion = onCompletion
        
        contentContainer.backgroundColor = tracker.color
        titleLabel.text = tracker.title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .ypWhite
        emojiLabel.font = .systemFont(ofSize: 16,weight: .medium)
        emojiLabel.text = String(tracker.emoji)
        
        footerContainer.backgroundColor = .ypWhite

        daysLabel.text = "\(completionCount) дней"
        daysLabel.textColor = .ypBlack
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        let actuallyCompleted = TrackerStore.shared.isCompleted(
            trackerId: tracker.id.uuidString,
            date: date)
        
        updateCompletionButton(isCompleted: actuallyCompleted, color: tracker.color)
    }
    
    private func updateCompletionButton(isCompleted: Bool, color: UIColor) {
        let buttonImage = isCompleted ?
        UIImage(systemName: "checkmark") :
        UIImage(systemName: "plus")
        
        completionButton.setImage(buttonImage, for: .normal)
        completionButton.backgroundColor = isCompleted ? color.withAlphaComponent(0.6) : color
        completionButton.tintColor = isCompleted ? .white.withAlphaComponent(0.6) : .white
    }

    @objc private func completionButtonTapped() {
           guard let trackerId = trackerId, let date = currentDate else { return }
           
           if date > Date() {
               print("Нельзя отмечать будущие даты")
               return
           }
           
           let currentlyCompleted = TrackerStore.shared.isCompleted(trackerId: trackerId, date: date)
           onCompletion?(trackerId, date, !currentlyCompleted)
       }
}
