import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerViewControllerSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        isRecording = false// Меняй на true для записи новых скриншотов
    }
    
    func test_trackerViewController_lightTheme() {
        let vc = TrackerViewController()
        vc.loadViewIfNeeded()
        
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13),
            named: "light_theme"
        )
    }
    
    func test_trackerViewController_darkTheme() {
        let vc = TrackerViewController()
        vc.overrideUserInterfaceStyle = .dark
        vc.loadViewIfNeeded()
        
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13),
            named: "dark_theme"
        )
    }
}
