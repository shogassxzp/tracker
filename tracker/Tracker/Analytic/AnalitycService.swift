import AppMetricaCore
import Foundation

final class AnalitycService {
    static let shared = AnalitycService()

    private init() {}

    func reportScreenOpen(_ screen: Screen) {
        let event: [String: Any] = [
            "event": "open",
            "screen": screen.rawValue,
        ]
        AppMetrica.reportEvent(name: "event", parameters: event, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    func reportScreenClose(_ screen: Screen) {
        let event: [String: Any] = [
            "event": "close",
            "screen": screen.rawValue,
        ]
        AppMetrica.reportEvent(name: "event", parameters: event, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    // MARK: - Click Events

    func reportClick(screen: Screen, item: ClickItem) {
        let event: [String: Any] = [
            "event": "click",
            "screen": screen.rawValue,
            "item": item.rawValue,
        ]
        AppMetrica.reportEvent(name: "event", parameters: event, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    // MARK: - Track Completion

    func reportTrackCompletion() {
        let event: [String: Any] = [
            "event": "click",
            "screen": Screen.main.rawValue,
            "item": ClickItem.track.rawValue,
        ]
        AppMetrica.reportEvent(name: "event", parameters: event, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

enum Screen: String {
    case main = "Main"
}

enum ClickItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}
