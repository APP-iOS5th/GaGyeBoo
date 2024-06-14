import UIKit



// Jua
// SongMyung
extension UILabel {
    func setCustomFont() {
        guard let customFont = UIFont(name: "Jua", size: self.font.pointSize) else {
            return
        }
        self.font = customFont
    }
}

extension UIButton {
    func setCustomFont() {
        guard let customFont = UIFont(name: "Jua", size: self.titleLabel?.font.pointSize ?? UIFont.labelFontSize) else {
            return
        }
        self.titleLabel?.font = customFont
    }
}

extension UITextField {
    func setCustomFont() {
        guard let customFont = UIFont(name: "Jua", size: self.font?.pointSize ?? UIFont.labelFontSize) else {
            return
        }
        self.font = customFont
    }
}

extension UITextView {
    func setCustomFont() {
        guard let customFont = UIFont(name: "Jua", size: self.font?.pointSize ?? UIFont.labelFontSize) else {
            return
        }
        self.font = customFont
    }
}

class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setCustomFont()
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

protocol ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel, isDeleted: Bool)
}

protocol ShowAlertDelegate {
    func showAlert(controller: UIAlertController)
}

protocol ShowEditDelegate {
    func showEditPage(controller: UIViewController, selectedSpend: GaGyeBooModel)
}
