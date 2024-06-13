import UIKit

class BudgetSettingViewController: UIViewController {
    
    private let budgetSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "월 예산 설정"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let budgetTextField: BudgetTextField = {
        let textField = BudgetTextField()
        textField.placeholder = "예산을 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let wonLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        let storedBudget = UserDefaults.standard.integer(forKey: "budgetAmount")
        budgetTextField.text = "\(storedBudget)"
        
        navigationController?.navigationBar.tintColor = .primary100
    }
    
    private func setupViews() {
        title = "예산 설정"
        view.backgroundColor = .bg100
        
        let saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        view.addSubview(budgetSectionLabel)
        view.addSubview(budgetTextField)
        view.addSubview(wonLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            budgetSectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            budgetSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            
            budgetTextField.topAnchor.constraint(equalTo: budgetSectionLabel.bottomAnchor, constant: 16),
            budgetTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            wonLabel.centerYAnchor.constraint(equalTo: budgetTextField.centerYAnchor),
            wonLabel.leadingAnchor.constraint(equalTo: budgetTextField.trailingAnchor, constant: 8)
        ])
    }
    
    @objc private func saveButtonTapped() {
        guard let budgetText = budgetTextField.text, !budgetText.isEmpty else {
            showAlert(title: "오류", message: "예산을 입력해 주세요.")
            return
        }
        
        let budget = Int(budgetText) ?? 0
        
        // Save the budget data to UserDefaults
        UserDefaults.standard.set(budget, forKey: "budgetAmount")
        
        print("Saved budget: \(budget)")
        
        // Navigate back to the previous view controller
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
