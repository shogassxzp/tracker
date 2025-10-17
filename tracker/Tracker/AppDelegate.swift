import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
            let categories = try categoryStore.fetchCategories()
            if categories.isEmpty {
                let defaultCategory = TrackerCategory(
                    id: UUID(),
                    title: "Важное"
                )
                try categoryStore.addCategory(defaultCategory)
                print("Создана дефолтная категория")
            } else {
                print("Категории существуют")
            }
        } catch {
            print("Ошибка создания дефолтоной категории")
        }
    }
}
