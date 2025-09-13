import UIKit

final class newTrackerViewController: UIViewController {
    private let newHabitLabel = UILabel()
    private let nameTextField = UITextField()
    private let categoryButton = UIButton()
    private let scheludeButton = UIButton()
    private let createButton = UIButton()
    private let delinceButton = UIButton()
    private let buttonStackView = UIStackView()
    private let separator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteDay
        addSubview()
        setupView()
        setupStackView()
    }

    private func addSubview() {
        [newHabitLabel, nameTextField, createButton, delinceButton, buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)

            [categoryButton, separator, scheludeButton].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                buttonStackView.addArrangedSubview($0)
            }
        }
    }

    private func setupView() {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        
        newHabitLabel.text = "Новая привычка"
        newHabitLabel.font = .systemFont(ofSize: 16, weight: .medium)

        nameTextField.placeholder = "Введите название трекера"
        nameTextField.leftView = leftPaddingView
        nameTextField.leftViewMode = .always
        nameTextField.textAlignment = .left
        nameTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameTextField.backgroundColor = .backgroundDay
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.cornerRadius = 16
        

        categoryButton.setTitle("  Категория", for: .normal)
        categoryButton.setTitleColor(.blackDay, for: .normal)
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.tintColor = .gray

        scheludeButton.setTitle("  Расписание", for: .normal)
        scheludeButton.setTitleColor(.blackDay, for: .normal)
        scheludeButton.contentHorizontalAlignment = .left
        scheludeButton.addTarget(self, action: #selector(scheludeTouchUp), for: .touchUpInside)

        delinceButton.setTitle("Отменить", for: .normal)
        delinceButton.setTitleColor(.systemRed, for: .normal)
        delinceButton.backgroundColor = .whiteDay
        delinceButton.layer.borderWidth = 1.0
        delinceButton.layer.borderColor = UIColor.systemRed.cgColor
        delinceButton.layer.cornerRadius = 16
        delinceButton.addTarget(self, action: #selector(delinceTouchUp), for: .touchUpInside)

        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.whiteDay, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16

        NSLayoutConstraint.activate([
            newHabitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            buttonStackView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor, constant: -16),

            categoryButton.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            scheludeButton.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor),
            scheludeButton.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor),
            scheludeButton.heightAnchor.constraint(equalToConstant: 75),

            delinceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            delinceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            delinceButton.heightAnchor.constraint(equalToConstant: 60),
            delinceButton.widthAnchor.constraint(equalToConstant: 166),

            createButton.leadingAnchor.constraint(equalTo: delinceButton.trailingAnchor, constant: 8),
            createButton.topAnchor.constraint(equalTo: delinceButton.topAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),

        ])
    }

    private func setupStackView() {
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fill
        buttonStackView.spacing = 1
        buttonStackView.layer.masksToBounds = true
        buttonStackView.layer.cornerRadius = 15
        buttonStackView.backgroundColor = .backgroundDay

        separator.backgroundColor = .separator
    }

    @objc private func delinceTouchUp() {
        let viewController = self
        viewController.dismiss(animated: true)
    }

    @objc private func scheludeTouchUp() {
        let scheludeViewController = ScheludeViewController()
        scheludeViewController.modalPresentationStyle = .popover
        present(scheludeViewController, animated: true)
    }
}
