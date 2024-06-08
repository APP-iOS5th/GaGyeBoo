import UIKit


class StatisticsTableCell: UITableViewCell {
    
    static let identifier = "StatisticsTableCell"
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier reuseIndentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIndentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.addSubview(monthLabel)
        contentView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            monthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with month: String, amount: String, isIncome: Bool) {
        monthLabel.text = month
        amountLabel.text = amount
        amountLabel.textColor = isIncome ? .systemBlue : .systemRed
    }
    
}
