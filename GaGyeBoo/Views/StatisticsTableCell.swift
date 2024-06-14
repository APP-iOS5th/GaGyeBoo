import UIKit

class StatisticsTableCell: UITableViewCell {
    static let identifier = "StatisticsTableCell"
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textAlignment = .left
        return label
    }()
    
    private let incomeAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .text200
        label.textAlignment = .right
        return label
    }()
    
    private let expenseAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .accent100
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(monthLabel)
        contentView.addSubview(incomeAmountLabel)
        contentView.addSubview(expenseAmountLabel)
        
        NSLayoutConstraint.activate([
            monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            monthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            incomeAmountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            incomeAmountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            expenseAmountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            expenseAmountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
        ])
    }
    
    func configure(with month: String, incomeAmount: String?, expenseAmount: String?) {
        monthLabel.text = month
        if let income = incomeAmount {
            incomeAmountLabel.isHidden = false
            incomeAmountLabel.text = "+ \(income)"
        } else {
            incomeAmountLabel.isHidden = true
        }
        
        if let expense = expenseAmount {
            expenseAmountLabel.isHidden = false
            expenseAmountLabel.text = "- \(expense)"
        } else {
            expenseAmountLabel.isHidden = true
        }
        
        layoutIfNeeded()
    }
}
