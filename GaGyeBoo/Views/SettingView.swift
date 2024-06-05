import UIKit

class SettingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        settingView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        settingView()
    }
    
    private func settingView() {
        backgroundColor = .black
        let label = UILabel()
        label.text = "설정"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
}

