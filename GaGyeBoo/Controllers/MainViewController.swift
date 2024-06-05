import UIKit

class MainViewController: UIViewController {
    private let picker: UISegmentedControl = {
        let pk = UISegmentedControl(items: ["일간", "월간"])
        pk.translatesAutoresizingMaskIntoConstraints = false
        pk.selectedSegmentIndex = 0
        
        return pk
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        return scroll
    }()
    
    private let contentView: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        
        return uv
    }()
    
    private let secondContentView: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        
        return uv
    }()
    
    private lazy var calendarView: UICalendarView = {
        var calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.isUserInteractionEnabled = true
        calendar.wantsDateDecorations = true
        calendar.delegate = self
        calendar.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        
        return calendar
    }()
    
    private let mockData = MockStruct()
    private var currentSpend: [GaGyeBooModel] = []
    private var tempSpendView: [UIView] = []
    private var prevBottomAnchorForScrollView: NSLayoutYAxisAnchor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setNavigationComponents()
        setSegmentPicker()
        setScrollView()
        setCalendarData()
        setCalendarView()
        setSpendList(year: 2024, month: 6, day: 7)
    }
    
    func setNavigationComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(toAddPage))
    }
    
    func setSegmentPicker() {
        view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func setScrollView() {
        scrollView.addSubview(contentView)
        scrollView.addSubview(secondContentView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            secondContentView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            secondContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            secondContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            secondContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            secondContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        prevBottomAnchorForScrollView = secondContentView.topAnchor
    }
    
    func setCalendarData() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        currentSpend = mockData.getSampleDataBy(year: currentYear, month: currentMonth)
    }
    
    func setCalendarView() {
        contentView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: contentView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setSpendList(year: Int, month: Int, day: Int) {
        // TODO: 일별 수입/지출 내역 리스트 표시
        let spendList = mockData.getSampleDataBy(year: year, month: month, day: day)
        prevBottomAnchorForScrollView = secondContentView.topAnchor
        
        for (idx, spend) in spendList.enumerated() {
            
            let category = spend.category
            let date = spend.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateText = dateFormatter.string(from: date)
            //let spendType = spend.spendType
            let amount = spend.amount
            let saveType = spend.saveType
            
            let categoryLabel = UILabel()
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            categoryLabel.text = category
            categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            
            let dateLabel = UILabel()
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.text = dateText
            dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            dateLabel.textColor = .lightGray
            
            let amountLabel = UILabel()
            amountLabel.translatesAutoresizingMaskIntoConstraints = false
            amountLabel.text = "\(saveType == .income ? "+" : "-")\(Int(amount))원"
            amountLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            amountLabel.textColor = saveType == .income ? .systemBlue : .systemRed
            
            let seperator = HorizontalSeparator()
            
            [categoryLabel, dateLabel, amountLabel, seperator].forEach{ secondContentView.addSubview($0) }
            
            NSLayoutConstraint.activate([
                categoryLabel.topAnchor.constraint(equalTo: prevBottomAnchorForScrollView, constant: 10),
                categoryLabel.leadingAnchor.constraint(equalTo: secondContentView.leadingAnchor, constant: 10),
                
                dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
                dateLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
                
                amountLabel.topAnchor.constraint(equalTo: prevBottomAnchorForScrollView, constant: 10),
                amountLabel.trailingAnchor.constraint(equalTo: secondContentView.trailingAnchor, constant: -10),
                
                seperator.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
                seperator.leadingAnchor.constraint(equalTo: secondContentView.leadingAnchor, constant: 10),
                seperator.trailingAnchor.constraint(equalTo: secondContentView.trailingAnchor, constant: 10),
            ])
            
            [categoryLabel, dateLabel, amountLabel, seperator].forEach{ tempSpendView.append($0) }
            
            prevBottomAnchorForScrollView = seperator.bottomAnchor
            if idx == spendList.count - 1 {
                seperator.bottomAnchor.constraint(equalTo: secondContentView.bottomAnchor, constant: -10).isActive = true
            }
        }
    }
    
    @objc func toAddPage() {
        // TODO: 수입/지출 내역 작성 페이지로 이동
    }
}

extension MainViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let models = currentSpend.filter { $0.date == dateComponents.date }
        
        // MARK: - 월을 변경하면 UIStackView의 위치가 깨지는 현상 있음
        if models.count > 0 {
            return .customView {
                let vStack = UIStackView()
                vStack.translatesAutoresizingMaskIntoConstraints = false
                vStack.axis = .vertical
                vStack.alignment = .center

                var income: Double = 0
                var expense: Double = 0
                models.forEach { model in
                    switch model.saveType {
                    case .income:
                        income += model.amount
                    case .expense:
                        expense += model.amount
                    }
                }
                if income > 0 {
                    let incomeLabel = UILabel()
                    incomeLabel.font = UIFont.systemFont(ofSize: 9)
                    incomeLabel.textColor = .systemBlue
                    incomeLabel.text = "+\(Int(income))"

                    vStack.addArrangedSubview(incomeLabel)
                }
                if expense > 0 {
                    let expenseLabel = UILabel()
                    expenseLabel.font = UIFont.systemFont(ofSize: 9)
                    expenseLabel.textColor = .systemRed
                    expenseLabel.text = "-\(Int(expense))"

                    vStack.addArrangedSubview(expenseLabel)
                }

                return vStack
            }
        }
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
        tempSpendView.forEach{ $0.removeFromSuperview() }
        tempSpendView.removeAll()
        
        if let dateComponent = dateComponents,
            let year = dateComponent.year,
            let month = dateComponent.month,
            let day = dateComponent.day {
            
            self.setSpendList(year: year, month: month, day: day)
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}

class HorizontalSeparator: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
