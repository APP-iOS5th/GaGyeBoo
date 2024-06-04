import UIKit

class StatisticsViewController: UIViewController {
    
    override func loadView() {
        self.view = StatisticsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "통계"
    }
}
