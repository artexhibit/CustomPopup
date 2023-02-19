
import UIKit

class PopupQueueManager {
    static let shared = PopupQueueManager()
    init() {}
    
    var popupViewsData = [(title: String, description: String, symbol: String, type: PopupView.BehaviourType)]()
    var hasDisplayingPopup = false
    var currentPopup: PopupView?
    
    func addPopupToQueue(title: String, description: String, symbol: String, type: PopupView.BehaviourType) {
        if !popupViewsData.isEmpty && type == .manual {
            currentPopup!.hidePopup(animSpeed: 0.1)
        }
        popupViewsData.append((title: title, description: description, symbol: symbol, type: type))
        let popup = PopupView()
        currentPopup = popup
        showNextPopupView()
    }
    
    func showNextPopupView() {
        guard !popupViewsData.isEmpty && !hasDisplayingPopup else { return }
        hasDisplayingPopup = true
        currentPopup!.showPopup(title: popupViewsData.first!.title, message: popupViewsData.first!.description, symbol: popupViewsData.first!.symbol, type: popupViewsData.first!.type)
    }
    
    func changePopupDataInQueue(title: String, message: String, symbol: String, type: PopupView.BehaviourType) {
        if hasDisplayingPopup {
            currentPopup!.changePopupData(title: title, message: message, symbol: symbol, type: type)
        }
    }
}
