import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "habit"

    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with tracker: Tracker) {
        titleLabel.text = tracker.title
        contentView.backgroundColor = .ypLightGray // tracker.color
    }
}
