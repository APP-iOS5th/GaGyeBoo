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
    
    private lazy var currentMonthSpendLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    private lazy var prevMonthSpendLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .lightGray
        
        return label
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
//    private var mockData = MockStruct(generateYear: 2024)
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())
    private let currentDay = Calendar.current.component(.day, from: Date())
    private var currentSpend: [GaGyeBooModel] = []
    private var spendList: [GaGyeBooModel] = []
    private var tempSpendView: [UIView] = []
    private var prevBottomAnchorForScrollView: NSLayoutYAxisAnchor!
    private var cancellable: Cancellable?
    private lazy var prevMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth - 1)
    private lazy var currentMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mockData.getSampleDataBy(year: 2024).forEach{ dataManager.saveSpend(newSpend: $0) }
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
        setPrevLabel()
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
            self?.currentSpend = spend
        }
        
        cancellable?.cancel()
        cancellable = dataManager.$spendsForDetailList.sink { [weak self] spend in
            self?.spendList = spend
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
    
    func setPrevLabel() {
        contentView.addSubview(currentMonthSpendLabel)
        contentView.addSubview(prevMonthSpendLabel)
        
        NSLayoutConstraint.activate([
            currentMonthSpendLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            currentMonthSpendLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            prevMonthSpendLabel.topAnchor.constraint(equalTo: currentMonthSpendLabel.bottomAnchor, constant: 5),
            prevMonthSpendLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
        
        updateSpendLabels(month: currentMonth)
    }
    
    private func updateSpendLabels(month: Int) {
        guard let prevMonthSpend = prevMonthSpend, let currentMonthSpend = currentMonthSpend else { return }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let spendLabelText = numberFormatter.string(from: NSNumber(value: abs(currentMonthSpend))) ?? ""
        
        currentMonthSpendLabel.text = "\(month)월 사용금액: \(spendLabelText)원"
        let comparePrevAndCurrentMonthSpend = Int(prevMonthSpend - currentMonthSpend) / 10000
        let spendStr: String
        if comparePrevAndCurrentMonthSpend < 0 {
            spendStr = "지난달보다 약 \(-comparePrevAndCurrentMonthSpend)만원 더 썼어요."
//            prevMonthSpendLabel.textColor = .red
        } else {
            spendStr = "지난달보다 약 \(comparePrevAndCurrentMonthSpend)만원 덜 썼어요."
//            prevMonthSpendLabel.textColor = .blue
        }
        prevMonthSpendLabel.text = spendStr
    }
    
    func setCalendarData() {
//        dataManager.getRecordsBy(year: currentYear, month: currentMonth, day: currentDay)
        setSpendList()
    }
    
    func setCalendarView() {
        contentView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: prevMonthSpendLabel.bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setSpendList() {
        prevBottomAnchorForScrollView = secondContentView.topAnchor
        
        for (idx, spend) in spendList.enumerated() {
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
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let amountText = numberFormatter.string(from: NSNumber(value: abs(amount))) ?? ""
            amountLabel.text = "\(saveType == .income ? "+" : "-")\(amountText)원"
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
                seperator.trailingAnchor.constraint(equalTo: secondContentView.trailingAnchor, constant: -10),
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
            if idx == spendList.count - 1 {
                seperator.bottomAnchor.constraint(equalTo: secondContentView.bottomAnchor, constant: -10).isActive = true
            }
        }
    }
    
    @objc func toAddPage() {
        // TODO: 수입/지출 내역 작성 페이지로 이동
        let addPageController = AddViewController()
        addPageController.calendarDelegate = self
        let navigationController = UINavigationController(rootViewController: addPageController)
        present(navigationController, animated: true)
    }
}

extension MainViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        let dateString = dateFormatter.string(from: date)
        
        let models = currentSpend.filter { $0.dateStr == dateString }
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
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                
                if income > 0 {
                    let incomeLabel = UILabel()
                    incomeLabel.font = UIFont.systemFont(ofSize: 9)
                    incomeLabel.textColor = .systemBlue
                    let amountText = numberFormatter.string(from: NSNumber(value: abs(Int(income)))) ?? ""
                    incomeLabel.text = "+\(amountText)"
                    
                    vStack.addArrangedSubview(incomeLabel)
                }
                if expense > 0 {
                    let expenseLabel = UILabel()
                    expenseLabel.font = UIFont.systemFont(ofSize: 9)
                    expenseLabel.textColor = .systemRed
                    let amountText = numberFormatter.string(from: NSNumber(value: abs(Int(expense)))) ?? ""
                    expenseLabel.text = "-\(amountText)"
                    
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
            
            dataManager.getRecordsBy(year: year, month: month, day: day)
            self.setSpendList()
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        if let newYear = calendarView.visibleDateComponents.year, let newMonth = calendarView.visibleDateComponents.month {
            currentMonthSpend = dataManager.getPrevExpense(year: newYear, month: newMonth)
            prevMonthSpend = dataManager.getPrevExpense(year: newYear, month: newMonth - 1)
            updateSpendLabels(month: newMonth)
            
        }
        calendarView.reloadDecorations(forDateComponents: [calendarView.visibleDateComponents], animated: true)
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


