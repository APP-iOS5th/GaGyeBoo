import UIKit
import Combine



extension UIColor {
    static let paperColor = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1.0) // #F5F5DC
    static let softColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)  // #F0F0F0
    static let warmColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1.0)  // #E4E4E4
    static let brightColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0) // #D3D3D3
    static let lightColor = UIColor(red: 201/255, green: 201/255, blue: 201/255, alpha: 1.0)  // #C9C9C9
    static let primary100 = UIColor(red: 1/255, green: 155/255, blue: 152/255, alpha: 1.0)  // #019b98
    static let primary200 = UIColor(red: 85/255, green: 204/255, blue: 201/255, alpha: 1.0)  // #55ccc9
    static let primary300 = UIColor(red: 193/255, green: 255/255, blue: 255/255, alpha: 1.0)  // #c1ffff
    static let accent100 = UIColor(red: 221/255, green: 0/255, blue: 37/255, alpha: 1.0)  // #dd0025
    static let accent200 = UIColor(red: 255/255, green: 191/255, blue: 171/255, alpha: 1.0)  // #ffbfab
    static let text100 = UIColor(red: 1/255, green: 78/255, blue: 96/255, alpha: 1.0)  // #014e60
    static let text200 = UIColor(red: 63/255, green: 122/255, blue: 141/255, alpha: 1.0)  // #3f7a8d
    static let bg100 = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0)  // #fbfbfb
    static let bg200 = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)  // #f1f1f1
    static let bg300 = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)  // #c8c8c8
    static let tempBlue = UIColor(red: 0, green: 112/255, blue: 192/255, alpha: 1)
    static let tempBlue2 = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
    static let textBlue = UIColor(red: 0/255, green: 119/255, blue: 194/255, alpha: 1)
}

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
        calendar.tintColor = .primary100
        
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
//        mockData.getSampleDataBy(year: 2024).forEach{ dataManager.saveSpend(newSpend: $0) }
        dataManager.getRecordsBy(year: currentYear, month: currentMonth, target: .calendar)
        setDailySpendView()
        // setMonthlySpendView()
    }
    
    func setDailySpendView() {
        view.backgroundColor = .bg100
        
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
        // +버튼 오른쪽 아래 float?버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(toAddPage))
        navigationItem.rightBarButtonItem?.tintColor = .primary100
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
        } else {
            spendStr = "지난달보다 약 \(comparePrevAndCurrentMonthSpend)만원 덜 썼어요."
        }
        prevMonthSpendLabel.text = spendStr
    }
    
    func setCalendarData() {
        dataManager.getRecordsBy(year: currentYear, month: currentMonth, day: currentDay, target: .list)
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
            amountLabel.textColor = saveType == .income ? .textBlue : .accent100
            
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
//        addPageController.calendarDelegate = self
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
//        print("=========================")
//        print(currentSpend.map{ $0.dateStr })
//        print(dateString)
        let models = currentSpend.filter { $0.dateStr == dateString }
//        print(models)
//        print("=========================")
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
                    incomeLabel.textColor = .textBlue
                    let amountText = numberFormatter.string(from: NSNumber(value: abs(Int(income)))) ?? ""
                    incomeLabel.text = "+\(amountText)"
                    
                    vStack.addArrangedSubview(incomeLabel)
                }
                if expense > 0 {
                    let expenseLabel = UILabel()
                    expenseLabel.font = UIFont.systemFont(ofSize: 9)
                    expenseLabel.textColor = .accent100
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
            
            dataManager.getRecordsBy(year: year, month: month, day: day, target: .list)
            self.setSpendList()
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        if let newYear = calendarView.visibleDateComponents.year, let newMonth = calendarView.visibleDateComponents.month {
            currentMonthSpend = dataManager.getPrevExpense(year: newYear, month: newMonth)
            prevMonthSpend = dataManager.getPrevExpense(year: newYear, month: newMonth - 1)
            updateSpendLabels(month: newMonth)
            dataManager.getRecordsBy(year: newYear, month: newMonth, target: .calendar)
            
            if let recentSpend = currentSpend.last {
                calendarView.visibleDateComponents.day = Int(recentSpend.dateStr.components(separatedBy: "-")[2])
                calendarView.reloadDecorations(forDateComponents: [calendarView.visibleDateComponents], animated: true)
            }
        }
    }
}

extension MainViewController: ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel) {
        tempSpendView.forEach{ $0.removeFromSuperview() }
        tempSpendView.removeAll()
        
//        dataManager.getRecordsBy(year: currentYear, month: currentMonth, target: .calendar)
        currentSpend.append(newSpend)
        dataManager.getRecordsBy(year: currentYear, month: currentMonth, day: currentDay, target: .list)
        
        print(calendarView.visibleDateComponents)
        calendarView.visibleDateComponents.day = Int(newSpend.dateStr.components(separatedBy: "-")[2])
        calendarView.reloadDecorations(forDateComponents: [calendarView.visibleDateComponents], animated: true)
        self.setSpendList()
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

protocol ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel)
}

enum ShowTarget {
    case calendar
    case list
}

extension UIColor {
    // Hex 문자열을 UIColor로 변환하는 이니셜라이저
    convenience init?(hex: String) {
        // 입력된 Hex 문자열을 정리
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        // Hex 문자열이 유효한지 확인
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        let r, g, b, a: CGFloat
        
        // Hex 문자열 길이에 따른 색상 값 추출
        switch length {
        case 6: // RGB (24비트)
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RGBA (32비트)
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }
        
        // UIColor 객체 생성
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
