import UIKit

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

extension UIResponder {
  
  func getOwningViewController() -> UIViewController? {
    var nextResponser = self
    while let next = nextResponser.next {
      nextResponser = next
      if let viewController = nextResponser as? UIViewController {
        return viewController
      }
    }
    return nil
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
