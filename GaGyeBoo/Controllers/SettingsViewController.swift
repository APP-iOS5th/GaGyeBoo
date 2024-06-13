import UIKit

class SettingsViewController: UIViewController, SettingsViewDelegate {
    private let settingsView = SettingsView()
    
    override func loadView() {
        self.view = settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsView.delegate = self
        title = "설정"
    }
    
    func showBudgetSettingViewController() {
        let budgetSettingVC = BudgetSettingViewController()
        navigationController?.pushViewController(budgetSettingVC, animated: true)
    }
    
    func showRecurringExpenseSettingViewController() {
        let recurringExpenseSettingVC = RecurringExpenseSettingViewController()
        navigationController?.pushViewController(recurringExpenseSettingVC, animated: true)
    }
    
    func showInquiryViewController() {
        let inquiryVC = InquiryViewController()
        navigationController?.pushViewController(inquiryVC, animated: true)
    }
}
