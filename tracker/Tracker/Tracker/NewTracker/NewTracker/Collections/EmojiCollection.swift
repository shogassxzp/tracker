import UIKit

final class EmojiCollection: UICollectionView {
    private let emojis: [Character] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡",
        "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸",
        "🏝", "😪",
    ]

    var onEmojiSelected: ((Character) -> Void)?
    private var selectedIndexPath: IndexPath?

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5

        super.init(frame: .zero, collectionViewLayout: layout)

        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        delegate = self
        dataSource = self
        register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        register(HeaderViewNewTracker.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerNewTracker")
        backgroundColor = .clear
        allowsMultipleSelection = false
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension EmojiCollection: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }

        let emoji = emojis[indexPath.item]
        cell.configure(with: emoji, isSelected: indexPath == selectedIndexPath)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerNewTracker",
                for: indexPath
            ) as? HeaderViewNewTracker
            
            header?.titleLabel.text = "Эмодзи"
            header?.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)

            return header ?? UICollectionReusableView()
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.bounds.width, height: 25)
        }
}

extension EmojiCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let selectedEmoji = emojis[indexPath.item]
        onEmojiSelected?(selectedEmoji)
        collectionView.reloadData()
    }
}

extension EmojiCollection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 5
        let totalWidth = collectionView.bounds.width
        let itemsPerRow: CGFloat = 6
        let totalSpacing = spacing * (itemsPerRow - 1)
        let itemWidth = (totalWidth - totalSpacing) / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

final class EmojiCell: UICollectionViewCell {
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()

    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(selectionView)
        contentView.addSubview(emojiLabel)

        selectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            selectionView.heightAnchor.constraint(equalTo: selectionView.widthAnchor),

            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(with emoji: Character, isSelected: Bool) {
        emojiLabel.text = String(emoji)
        selectionView.isHidden = !isSelected
        backgroundColor = isSelected ? .lightGray.withAlphaComponent(0.3) : .clear
        layer.cornerRadius = isSelected ? 12 : 0
    }
}
