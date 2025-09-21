import UIKit

final class TabBarController: UITabBarController {
    private let trackerController = TrackerViewController()
    private let statsController = StatisticViewController()
    private let separator = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBar()
    }

    private func setupBar() {
        trackerController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackerLogo),
            tag: 1,
        )

        statsController.tabBarItem = UITabBarItem(
            title: "Статисткиа",
            image: UIImage(resource: .statsLogo),
            tag: 2
        )

        viewControllers = [trackerController, statsController]
        
        tabBar.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }
}
