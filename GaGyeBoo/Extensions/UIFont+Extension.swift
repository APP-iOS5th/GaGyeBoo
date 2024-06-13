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
