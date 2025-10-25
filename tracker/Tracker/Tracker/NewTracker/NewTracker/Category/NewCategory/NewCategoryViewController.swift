import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateNewCategory(_ category: TrackerCategory)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?
    private let categoryStore: TrackerCategoryStoreProtocol

    private var label: UILabel = {
        let label = UILabel()
        label.text = Localizable.newCategory
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        return label

    }()

    private var textField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .ypBackground
        field.placeholder = Localizable.enterCategoryName
        field.layer.cornerRadius = 16
        field.font = .systemFont(ofSize: 17, weight: .regular)

        return field
    }()

    private var button: UIButton = {
        let button = UIButton()
        button.setTitle(Localizable.done, for: .normal)
        button.backgroundColor = .ypGray
        button.tintColor = .ypWhite
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(nil, action: #selector(createCategory), for: .touchUpInside)

        return button
    }()

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldObserver()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.delegate = self

        [label, button, textField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        view.backgroundColor = .ypWhite

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

        ])
    }

    private func updateButton() {
        let isNameEmpty = textField.text?.isEmpty ?? true

        let isEnabled = !isNameEmpty
        button.isEnabled = isEnabled
        button.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }

    @objc private func createCategory() {
            guard let categoryName = textField.text, !categoryName.isEmpty else {
                return
            }
            
            let newCategory = TrackerCategory(id: UUID(), title: categoryName)
            
            do {
                try categoryStore.addCategory(newCategory)
                delegate?.didCreateNewCategory(newCategory)
                dismiss(animated: true)
            } catch {
                return
            }
        }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        textField.returnKeyType = .done
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        updateButton()
    }

    private func setupTextFieldObserver() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
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
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            warningLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
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
        updateButton()
    }
}
