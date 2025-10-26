import AppMetricaCore
import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = AppMetricaConfiguration(apiKey: "enter_your_api_key")
        configuration?.areLogsEnabled = true
        AppMetrica.activate(with: configuration!)

        _ = Dependencies.shared.coreDataStack

        createDefaultCategoryIfNeeded()

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
        Dependencies.shared.coreDataStack.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }

    private func createDefaultCategoryIfNeeded() {
        let categoryStore = Dependencies.shared.categoryStore

        do {
            let categories = try categoryStore.fetchAllCategories()
            if categories.isEmpty {
                let defaultCategory = TrackerCategory(
                    id: UUID(),
                    title: Localizable.imortant
                )
                try categoryStore.addCategory(defaultCategory)
            } else {
            }
        } catch {
            return
        }
    }
}
