import UIKit

final class TabBarController: UITabBarController {
    private let trackerController = TrackerViewController()
    private let statsController = StatisticViewController()

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

        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }
}
