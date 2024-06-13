import UIKit

class BudgetTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        keyboardType = .numberPad
        addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEndOnExit)
    }
    
    @objc private func textFieldDidEndEditing() {
        resignFirstResponder()
    }
    
}
