import UIKit

class CategoryButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = .primary200
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isSelected {
            backgroundColor = .primary100
        } else {
            backgroundColor = .systemBackground
        }
    }
}
