
import UIKit

class NewPopupTestViewController: UIViewController {
    
    let testMessages: [String] = [
        "Abra",
        "Abrakadabraaaaaaaaaa"
    ]
    var testIDX: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // a button to show the popup
        let btn: UIButton = {
            let b = UIButton()
            b.backgroundColor = .systemRed
            b.setTitle("Show Popup", for: [])
            b.setTitleColor(.white, for: .normal)
            b.setTitleColor(.lightGray, for: .highlighted)
            b.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            return b
        }()
        // a couple labels at the top so we can see the popup blur effect
        let label1: UILabel = {
            let v = UILabel()
            v.text = "Just some text to put near the top of the view"
            v.backgroundColor = .yellow
            v.textColor = .red
            return v
        }()
        
        let label2: UILabel = {
            let v = UILabel()
            v.text = "so we can see that the popup covers it."
            v.backgroundColor = .systemBlue
            v.textColor = .white
            return v
        }()
        [label1, label2].forEach { v in
            v.font = .systemFont(ofSize: 24.0, weight: .light)
            v.textAlignment = .center
            v.numberOfLines = 0
        }
        [btn, label1, label2].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: g.topAnchor, constant: 8.0),
            label1.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16.0),
            
            label2.topAnchor.constraint(equalTo: g.topAnchor, constant: 8.0),
            label2.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16.0),
            
            label2.leadingAnchor.constraint(equalTo: label1.trailingAnchor, constant: 12.0),
            label2.widthAnchor.constraint(equalTo: label1.widthAnchor),
            
            btn.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            btn.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            btn.widthAnchor.constraint(equalToConstant: 200.0),
            btn.heightAnchor.constraint(equalToConstant: 50.0),
        ])
    }
    
    @objc func tapped(_ sender: Any) {
        let msg = testMessages[testIDX % testMessages.count]
        PopupQueueManager.shared.addPopupToQueue(title: "Test \(testIDX)", description: msg, symbol: "spinner", type: .manual)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            PopupQueueManager.shared.changePopupDataInQueue(title: "New Title", message: msg, symbol: "square.and.arrow.up", type: .auto)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            PopupQueueManager.shared.addPopupToQueue(title: "Test \(self.testIDX)", description: msg, symbol: "spinner", type: .manual)
        }
        testIDX += 1
    }
}
