
import UIKit

class PopupQueueManager {
    static let shared = PopupQueueManager()
    init() {}
    
    var popupViewsData = [(title: String, description: String, symbol: String, type: PopupView.BehaviourType)]()
    var hasDisplayingPopup = false
    let popup = PopupView()
    
    func addPopupToQueue(title: String, description: String, symbol: String, type: PopupView.BehaviourType) {
        popupViewsData.append((title: title, description: description, symbol: symbol, type: type))
        showNextPopupView()
    }
    
    func showNextPopupView() {
        guard !popupViewsData.isEmpty && !hasDisplayingPopup else { return }
        hasDisplayingPopup = true
        popup.showPopup(title: popupViewsData.first!.title, message: popupViewsData.first!.description, symbol: popupViewsData.first!.symbol, type: popupViewsData.first!.type)
    }
    
    func changePopupData(title: String, message: String, symbol: String, type: PopupView.BehaviourType) {
        if hasDisplayingPopup {
            popup.changePopupData(title: title, message: message, symbol: symbol, type: type)
        }
    }
}
