import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if hasCompletedOnboarding {
            showMainScreen()
        } else {
            showOnboarding()
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func showOnboarding() {
        let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        onboardingViewController.onCompletion = { [weak self] in
            self?.completeOnboarding()
        }
        
        window?.rootViewController = onboardingViewController
    }
    
    private func showMainScreen() {
        let tabBarController = TabBarController()
        window?.rootViewController = tabBarController
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showMainScreen()
    }
}
