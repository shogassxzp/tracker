import UIKit

final class CategoriesViewController: UIViewController {
    private let viewModel: CategoriesViewModel
    private let onCategorySelect: ((TrackerCategory) -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.category
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.addCategory, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .ypWhite
        table.separatorStyle = .singleLine
        table.tableFooterView = UIView()
        table.layer.cornerRadius = 16
        table.clipsToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "\(Localizable.habitsCanBeGrouped)"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .collectionPlaceholder)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(categoryStore: TrackerCategoryStoreProtocol, onCategorySelect: ((TrackerCategory) -> Void)? = nil) {
        viewModel = CategoriesViewModel(categoryStore: categoryStore)
        self.onCategorySelect = onCategorySelect
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.loadCategories()
    }

    private func setupUI() {
        view.backgroundColor = .ypWhite

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyStateImage)
        emptyStateView.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImage.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImage.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
        ])
    }

    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        }

        viewModel.onCategorySelect = { [weak self] category in
            DispatchQueue.main.async {
                self?.onCategorySelect?(category)
                self?.dismiss(animated: true)
            }
        }
    }

    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    @objc private func addCategoryTapped() {
        let newCategoryViewController = NewCategoryViewController(categoryStore: Dependencies.shared.categoryStore)
        newCategoryViewController.delegate = self
        newCategoryViewController.modalPresentationStyle = .popover
        present(newCategoryViewController, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, NewCategoryViewControllerDelegate {
    func didCreateNewCategory(_ category: TrackerCategory) {
        viewModel.loadCategories()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)

        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            let deleteAction = UIAction(
                title: Localizable.delete,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.showDeleteConfirmation(for: indexPath)
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }

    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: Localizable.deleteCategoryConfirmation,
            message: nil,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: Localizable.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath)
        }

        let cancelAction = UIAlertAction(title: Localizable.cancel, style: .cancel)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        var corners: UIRectCorner = []

        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }

        if !corners.isEmpty {
            let path = UIBezierPath(
                roundedRect: cell.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            cell.layer.mask = mask
        } else {
            cell.layer.mask = nil
        }
    }
}
