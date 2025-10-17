import UIKit

final class OnboardingViewController: UIPageViewController {
    private var pages: [UIViewController] = []
    private var currentPageIndex = 0
    var onCompletion: (() -> Void)?

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 2
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .ypBlack
        control.pageIndicatorTintColor = .ypGray
        return control
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupView()
    }

    private func setupPages() {
        let firstPage = OnboardingContentViewController(
            imageName: "onboarding1",
            title: "Отслеживайте только то, что хотите"
        )

        let secondPage = OnboardingContentViewController(
            imageName: "onboarding2",
            title: "Даже если это не литры воды и йога"
        )

        pages = [firstPage, secondPage]

        setViewControllers([firstPage], direction: .forward, animated: true)
        dataSource = self
        delegate = self
    }

    private func setupView() {
        view.backgroundColor = .ypWhite

        view.addSubview(pageControl)
        view.addSubview(nextButton)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func nextButtonTapped() {
        onCompletion?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            currentPageIndex = index
            pageControl.currentPage = index
        }
    }
}
