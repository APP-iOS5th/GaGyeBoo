import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let settings: [[Setting]] = [
        [
            Setting(title: "예산 설정", action: nil),
            Setting(title: "고정 지출 설정", action: nil)
        ],
        [
            Setting(title: "문의하기", action: nil)
        ]
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureTableView()
    }
    
    private func setupViews() {
        title = "설정"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let setting = settings[indexPath.section][indexPath.row]
        cell.textLabel?.text = setting.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "자산 설정" : "고객센터"
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = settings[indexPath.section][indexPath.row]
        
        switch setting.title {
        case "예산 설정":
            let budgetSettingVC = BudgetSettingViewController()
            navigationController?.pushViewController(budgetSettingVC, animated: true)
        case "고정 지출 설정":
            let recurringExpenseSettingVC = RecurringExpenseSettingViewController()
            navigationController?.pushViewController(recurringExpenseSettingVC, animated: true)
        case "문의하기":
            let inquiryVC = InquiryViewController()
            navigationController?.pushViewController(inquiryVC, animated: true)
        default:
            break
            
        }
    }
}

struct Setting {
    let title: String
    let action: (() -> Void)?
}
