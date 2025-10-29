import UIKit

final class ColorCollection: UICollectionView {
    private let colors: [UIColor] = [
        .selectionRed, .selectionOrange, .selectionBlue, .selectionPurple, .selectionGreen, .selectionPink, .selectionLightPink, .selectionLightBlue, .selectionLightGreen, .selectionDarkBlue, .selectionLightOrange, .selectionPink2, .selectionLightYellow, .selectionLightBlue2, .selectionDarkPurple, .selectionDarkPurple2, .selectionLightPurple, .selectionDarkGreen2,
    ]

    var onColorSelected: ((UIColor) -> Void)?
    private var selectedIndexPath: IndexPath?

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5

        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        delegate = self
        dataSource = self
        register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        register(HeaderViewNewTracker.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerNewTracker")
        allowsMultipleSelection = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    func selectColor(_ color: UIColor) {
        if let index = colors.firstIndex(where: { areColorsEqual($0, color) }) {
            let indexPath = IndexPath(item: index, section: 0)
            selectedIndexPath = indexPath

            reloadData()

            onColorSelected?(color)
        } else {
            return
        }
    }

    private func areColorsEqual(_ color1: UIColor, _ color2: UIColor) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return abs(r1 - r2) < 0.01 &&
            abs(g1 - g2) < 0.01 &&
            abs(b1 - b2) < 0.01 &&
            abs(a1 - a2) < 0.01
    }
}

extension ColorCollection: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }

        let color = colors[indexPath.item]
        cell.configure(with: color, isSelected: indexPath == selectedIndexPath)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let selectedColor = colors[indexPath.item]
        onColorSelected?(selectedColor)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 5
        let totalWidth = collectionView.bounds.width
        let itemsPerRow: CGFloat = 6
        let totalSpacing = spacing * (itemsPerRow - 1)
        let itemWidth = (totalWidth - totalSpacing) / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth / 1.25)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerNewTracker",
                for: indexPath
            ) as? HeaderViewNewTracker

            header?.titleLabel.text = Localizable.color
            header?.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)

            return header ?? UICollectionReusableView()
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 25)
    }
}

final class ColorCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(colorView)
        contentView.addSubview(selectionView)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            selectionView.heightAnchor.constraint(equalTo: selectionView.widthAnchor),
        ])
    }

    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        selectionView.isHidden = !isSelected
        selectionView.layer.borderColor = color.withAlphaComponent(0.6).cgColor
    }
}
