import UIKit

class SettingViewController: UIViewController {
    
    override func loadView() {
        self.view = SettingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "설정"
    }
}
