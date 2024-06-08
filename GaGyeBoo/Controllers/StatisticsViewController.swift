import UIKit

class StatisticsViewController: UIViewController {
    
    override func loadView() {
        self.view = StatisticsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        self.title = "통계"
    }
}
