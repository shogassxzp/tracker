import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryTableViewCell"

    private let categoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemBlue
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: CategoryCellViewModel) {
        titleLabel.text = viewModel.title

        checkmarkImageView.isHidden = !viewModel.isSelected
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(categoryView)
        categoryView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        categoryView.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            categoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 32),
            categoryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: categoryView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -8),

            checkmarkImageView.trailingAnchor.constraint(equalTo: categoryView.trailingAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
}
