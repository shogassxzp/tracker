import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if TrackerStoree.shared.getCategories().isEmpty {
            let defaultCategory = TrackerCategory(
                id: UUID(),
                title: "Важное",
                trackers: []
            )
            TrackerStoree.shared.setCategories([defaultCategory])
        }
        _ = Dependencies.shared.coreDataStack

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Main",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    func saveContext() {
        Dependencies.shared.coreDataStack.saveContex()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
}
