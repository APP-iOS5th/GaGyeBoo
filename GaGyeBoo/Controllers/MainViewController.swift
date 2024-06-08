import UIKit
import Combine

class MainViewController: UIViewController {
    private lazy var picker: UISegmentedControl = {
        let pk = UISegmentedControl(items: ["일간", "월간"])
        pk.translatesAutoresizingMaskIntoConstraints = false
        /*
        TODO: picker의 값이 변경되면 그 값에 맞게 보여지는 화면 다르게 하기
        pk.addAction(UIAction { [weak self] _ in
            switch pk.selectedSegmentIndex {
            case 0:
                self?.setDailySpendView()
            case 1:
                self?.setMonthlySpendView()
            default:
                break
            }
        }, for: .valueChanged)
        */
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
    
    private let dataManager = SpendDataManager()
    private let mockData = MockStruct()
    private var currentSpend: [GaGyeBooModel] = []
    private var tempSpendView: [UIView] = []
    private var prevBottomAnchorForScrollView: NSLayoutYAxisAnchor!
    private var cancellable: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dataManager.saveSpend(newSpend: GaGyeBooModel(date: Date(), saveType: .income, category: "그냥", spendType: nil, amount: 100000))
        dataManager.getAllSpends()
        setDailySpendView()
        // setMonthlySpendView()
    }
    
    func setDailySpendView() {
        view.backgroundColor = .systemBackground
        
        setSubscriber()
        setNavigationComponents()
        setSegmentPicker()
        setScrollView()
        setCalendarData()
        setCalendarView()
    }
    
    func setMonthlySpendView() {
//        tempSpendView.forEach{ $0.removeFromSuperview() }
//        tempSpendView.removeAll()
//        view.backgroundColor = .yellow
    }
    
    func setSubscriber() {
        cancellable?.cancel()
        cancellable = dataManager.$allSpends.sink { [weak self] spend in
            guard let self = self else { return }
            self.currentSpend = spend
        }
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
        let currentDay = Calendar.current.component(.day, from: Date())
        setSpendList(year: currentYear, month: currentMonth, day: currentDay)
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
        prevBottomAnchorForScrollView = secondContentView.topAnchor
        
        for (idx, spend) in currentSpend.enumerated() {
            let category = spend.category
            let date = spend.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateText = dateFormatter.string(from: date)
            let spendType = spend.spendType
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
            
            if let spendType = spendType {
                let spendTypeLabel = UILabel()
                spendTypeLabel.translatesAutoresizingMaskIntoConstraints = false
                spendTypeLabel.text = spendType
                spendTypeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                spendTypeLabel.textColor = .lightGray
                
                tempSpendView.append(spendTypeLabel)
                secondContentView.addSubview(spendTypeLabel)
                
                NSLayoutConstraint.activate([
                    spendTypeLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 10),
                    spendTypeLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor)
                ])
            }
            
            prevBottomAnchorForScrollView = seperator.bottomAnchor
            if idx == currentSpend.count - 1 {
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
        if let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day {
            let models = currentSpend.filter { $0.dateStr == "\(year)-\(String(month).count == 1 ? "0\(month)" : "\(month)")-\(String(day).count == 1 ? "0\(day)" : "\(day)")" }
            // MARK: - UIStackView의 Constraint가 모호해서 위치가 깨지는 현상 있음
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
            
            dataManager.getRecordsBy(year: year, month: month, day: day)
            self.setSpendList(year: year, month: month, day: day)
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        if let newYear = calendarView.visibleDateComponents.year, let newMonth = calendarView.visibleDateComponents.month {
            dataManager.getRecordsBy(year: newYear, month: newMonth)
            calendarView.reloadDecorations(forDateComponents: [calendarView.visibleDateComponents], animated: true)
        }
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
