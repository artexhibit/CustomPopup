import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var popupView: UIVisualEffectView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var secondDescriptionLabel: UILabel!
    @IBOutlet weak var changeDescriptionLabel: UILabel!
    @IBOutlet weak var secondChangeDescriptionLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var labelLeftC: NSLayoutConstraint!
    @IBOutlet weak var changeLabelLeftC: NSLayoutConstraint!
    @IBOutlet weak var loadSpinner: UIActivityIndicatorView!
    
    private var timer: Timer?
    private var topConstraint: NSLayoutConstraint!
    private var botConstraint: NSLayoutConstraint!
    private var animationDuration: TimeInterval = 0.3
    private var labelScrollAnimationDuration: TimeInterval {
        return Double((descriptionLabel.text!.count)/4)
    }
    private var changeLabelScrollAnimationDuration: TimeInterval?
    private var mainLabelWidth: CGFloat {
        return descriptionLabel.intrinsicContentSize.width
    }
    private var changeMainLabelWidth: CGFloat?
    private var labelViewWidth: CGFloat {
        return labelView.frame.width
    }
    private var isScrollable: Bool {
        return mainLabelWidth > labelViewWidth ? true : false
    }
    private var isChangeScrollable: Bool?
    private let mainLabelLeadingBuffer = 10.0
    private let secondLabelLeadingBuffer = 40.0
    
    enum BehaviourType {
        case auto
        case manual
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        if let views = Bundle.main.loadNibNamed("PopupView", owner: self) {
            guard let view = views.first as? UIView else { return }
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            ])
        }
    }
    
    private func findWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return nil
        }
        return window
    }
    
    func showPopup(title: String, message: String, symbol: String, type: BehaviourType) {
        self.titleLabel.text = title
        self.descriptionLabel.text = message
        self.secondDescriptionLabel.text = message
        if symbol == "spinner" {
            self.symbol.isHidden = true
            self.loadSpinner.startAnimating()
        } else {
            self.symbol.image = UIImage(named: symbol)
        }
        self.backgroundColor = .clear
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        self.configurePopup()
        self.configureLabels()
        self.configureSwipeGesture()
        
        DispatchQueue.main.async {
            self.configurePopupBehaviour(according: type)
        }
    }
    
    func changePopupData(title: String, message: String, symbol: String, type: BehaviourType) {
        self.titleLabel.text = title
        self.changeDescriptionLabel.text = message
        self.secondChangeDescriptionLabel.text = message
        self.symbol.image = UIImage(named: symbol)
        self.symbol.isHidden = false
        self.loadSpinner.stopAnimating()
        
        var isCScrollable: Bool {
            return changeDescriptionLabel.intrinsicContentSize.width > labelViewWidth ? true : false
        }
        var labelChangeScrollAnimationDuration: TimeInterval {
            return Double((changeDescriptionLabel.text!.count)/4)
        }
        isChangeScrollable = isCScrollable
        changeLabelScrollAnimationDuration = labelChangeScrollAnimationDuration
        changeMainLabelWidth = changeDescriptionLabel.intrinsicContentSize.width
        
        self.configureChangeLabels()
        DispatchQueue.main.async {
            self.performChangeScrollFor(type: type, change: true)
        }
    }
    
    private func configurePopupBehaviour(according type: BehaviourType) {
        animateIn()
        
        switch type {
        case .auto:
            performScrollFor(type: type)
        case .manual:
            performScrollFor(type: type)
        }
    }
    
    private func performScrollFor(type: BehaviourType) {
        if isScrollable {
            scrollLabel()
            if type == .auto {
                hidePopup(afterSeconds: labelScrollAnimationDuration + 2.0)
            }
        } else {
            if type == .auto {
                hidePopup(afterSeconds: 2.0)
            }
        }
    }
    
    private func performChangeScrollFor(type: BehaviourType, change: Bool = false) {
        if isChangeScrollable ?? false {
            scrollChangeLabel()
            if type == .auto {
                hidePopup(afterSeconds: (changeLabelScrollAnimationDuration ?? 0) + 2.0)
            }
        } else {
            if type == .auto {
                hidePopup(afterSeconds: 2.0)
            }
        }
    }
    
    func hidePopup(afterSeconds delay: TimeInterval = 0.0) {
        self.timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.animateOut), userInfo: nil, repeats: false)
    }
    
    @objc private func animateOut() {
        guard let superView = self.superview else { return }
        self.topConstraint.isActive = false
        self.botConstraint.isActive = true
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) {
            superView.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
            PopupQueueManager.shared.popupViewsData.removeFirst()
            PopupQueueManager.shared.hasDisplayingPopup = false
            PopupQueueManager.shared.showNextPopupView()
        }
    }
    
    private func animateIn() {
        guard let superView = self.superview else { return }
        self.botConstraint.isActive = false
        self.topConstraint.isActive = true
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) {
            superView.layoutIfNeeded()
        }
    }
    
    private func scrollLabel() {
        guard let superView = self.superview else { return }
        labelLeftC.constant = 0 - mainLabelWidth - secondLabelLeadingBuffer + mainLabelLeadingBuffer
        UIView.animate(withDuration: self.labelScrollAnimationDuration, delay: 1.0, options: .curveLinear) {
            superView.layoutIfNeeded()
        }
    }
    
    private func scrollChangeLabel() {
        guard let superView = self.superview else { return }
        changeLabelLeftC.constant = 0 - changeMainLabelWidth! - secondLabelLeadingBuffer + mainLabelLeadingBuffer
        UIView.animate(withDuration: (self.changeLabelScrollAnimationDuration ?? 0), delay: 1.0, options: .curveLinear) {
            superView.layoutIfNeeded()
        }
    }
    
    private func configurePopup() {
        guard let window = findWindow() else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(self)

        self.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        botConstraint = self.bottomAnchor.constraint(equalTo: window.topAnchor, constant: -2.0)
        topConstraint = self.topAnchor.constraint(equalTo: window.topAnchor, constant: 32.0)
        botConstraint.isActive = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func configureLabels() {
        if isScrollable {
            secondDescriptionLabel.isHidden = false
            labelLeftC.constant = mainLabelLeadingBuffer
            setupGradient(on: labelView)
        } else {
            secondDescriptionLabel.isHidden = true
            labelLeftC.constant = (labelViewWidth / 2) - (mainLabelWidth / 2)
        }
    }
    
    private func configureChangeLabels() {
        if isChangeScrollable ?? false {
            secondChangeDescriptionLabel.isHidden = false
            changeLabelLeftC.constant = mainLabelLeadingBuffer
        } else {
            secondChangeDescriptionLabel.isHidden = true
            changeLabelLeftC.constant = (labelViewWidth / 2) - ((changeMainLabelWidth ?? 0) / 2)
        }
        changeDescriptionLabel.isHidden = false
        descriptionLabel.isHidden = true
        secondDescriptionLabel.isHidden = true
    }
    
    private func setupGradient(on view: UIView) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.1, 0.3, 0.9, 1]
        
        gradientLayer.frame = view.bounds
        view.layer.mask = gradientLayer
    }
    
    private func configureSwipeGesture() {
        let pg = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(pg)
        
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let superView = self.superview else { return }
        if sender.translation(in: superView).y < 0, let t = timer, t.isValid {
            t.invalidate()
            animateOut()
        }
    }
}
