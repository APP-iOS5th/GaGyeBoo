import UIKit

protocol SettingsViewDelegate: AnyObject {
    func showBudgetSettingViewController()
    func showRecurringExpenseSettingViewController()
    func showInquiryViewController()
}

struct Setting {
    let title: String
    let action: (() -> Void)?
}

class SettingsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: SettingsViewDelegate?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        configureTableView()
    }
    
    private func setupViews() {
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = settings[indexPath.section][indexPath.row]
        
        switch setting.title {
        case "예산 설정":
            delegate?.showBudgetSettingViewController()
        case "고정 지출 설정":
            delegate?.showRecurringExpenseSettingViewController()
        case "문의하기":
            delegate?.showInquiryViewController()
        default:
            break
        }
    }
}






