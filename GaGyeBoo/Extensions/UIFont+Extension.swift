import UIKit



// Jua-Regular
// SongMyung-Regular

enum CustomFont: String {
    case jua = "Jua-Regular"
    
    func withSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: self.rawValue, size: size)
    }
}

extension UILabel {
    func setCustomFont(_ customFont: CustomFont) {
        guard let font = customFont.withSize(self.font.pointSize) else {
            print("Failed to load \(customFont.rawValue) font")
            return
        }
        self.font = font
    }
}

extension UIButton {
    func setCustomFont(_ customFont: CustomFont) {
        guard let font = customFont.withSize(self.titleLabel?.font.pointSize ?? UIFont.labelFontSize) else {
            print("Failed to load \(customFont.rawValue) font")
            return
        }
        self.titleLabel?.font = font
    }
}

extension UITextField {
    func setCustomFont(_ customFont: CustomFont) {
        guard let font = customFont.withSize(self.font?.pointSize ?? UIFont.labelFontSize) else {
            print("Failed to load \(customFont.rawValue) font")
            return
        }
        self.font = font
    }
}

extension UITextView {
    func setCustomFont(_ customFont: CustomFont) {
        guard let font = customFont.withSize(self.font?.pointSize ?? UIFont.labelFontSize) else {
            print("Failed to load \(customFont.rawValue) font")
            return
        }
        self.font = font
    }
}






class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(
        text: String,
        size: CGFloat = 15,
        color: UIColor = .label
    ) {
        self.init()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.font = UIFont.systemFont(ofSize: size, weight: .bold)
        self.textColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomPopupImageButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(
        image: UIImage,
        tintColor: UIColor
    ) {
        self.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setImage(image, for: .normal)
        self.tintColor = tintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HorizontalSeparator: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Double {
    var DoubleWithSeperator: String {
        get {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let amountText = numberFormatter.string(from: NSNumber(value: abs(self))) ?? ""
            
            return amountText
        }
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

protocol ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel, isDeleted: Bool)
}

protocol ShowAlertDelegate {
    func showAlert(controller: UIAlertController)
}

protocol ShowEditDelegate {
    func showEditPage(controller: UIViewController, selectedSpend: GaGyeBooModel)
}
