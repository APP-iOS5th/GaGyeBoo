import UIKit
import Combine

class MainView: UIView {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let secondContentView = UIView()
    
    private lazy var calendarView: UICalendarView = {
        var calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.isUserInteractionEnabled = true
        calendar.wantsDateDecorations = true
        calendar.delegate = self
        calendar.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        calendar.tintColor = .primary100
        calendar.locale = Locale(identifier: "ko_KR")
        
        return calendar
    }()
    
    private var prevBottomAnchorForScrollView: NSLayoutYAxisAnchor!
    private var firstCancellable: Cancellable?
    private var secondCancellable: Cancellable?
    private var currentYearMonthSpends: [GaGyeBooModel] = []
    private var currentYearMonthDaySpends: [GaGyeBooModel] = []
    private var tempSpendView: [UIView] = []
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let currentMonth = Calendar.current.component(.month, from: Date())
    private let currentDay = Calendar.current.component(.day, from: Date())
    private let dataManager = SpendDataManager()
    var alertDelegate: ShowAlertDelegate?
    var editDelegate: ShowEditDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setSubscriber()
        configureUI()
        loadCurrentYearMonthData(year: currentYear, month: currentMonth)
        loadCurrentYearMonthDayData(year: currentYear, month: currentMonth, day: currentDay)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setSubscriber() {
        firstCancellable?.cancel()
        firstCancellable = dataManager.$currentYearMonthSpends.sink(receiveValue: { [weak self] spends in
            guard let self = self else { return }
            self.currentYearMonthSpends = spends
            self.calendarView.reloadDecorations(forDateComponents: [DateComponents(year: currentYear, month: currentMonth)], animated: true)
        })
        
        secondCancellable?.cancel()
        secondCancellable = dataManager.$currentYearMonthDaySpends.sink(receiveValue: { [weak self] spends in
            guard let self = self else { return }
            self.currentYearMonthDaySpends = spends
            self.calendarView.reloadDecorations(forDateComponents: [DateComponents(year: currentYear, month: currentMonth, day: currentDay)], animated: true)
        })
    }
    
    func configureUI() {
        self.backgroundColor = .systemBackground
        
        [scrollView].forEach{ self.addSubview($0) }
        [scrollView, contentView, secondContentView].forEach{ $0.translatesAutoresizingMaskIntoConstraints = false }
        
        setScrollView()
        setCalendarView()
        setDailySpendList()
    }
    
    func setScrollView() {
        scrollView.addSubview(contentView)
        scrollView.addSubview(secondContentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
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
    }
    
    func setCalendarView() {
        contentView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        prevBottomAnchorForScrollView = calendarView.bottomAnchor
        DispatchQueue.main.async {
            self.changeWeekdayHeaderColors()
        }
    }
    
    func changeWeekdayHeaderColors() {
        for subview in calendarView.subviews {
            for weekParent in subview.subviews[1].subviews {
                for weekLabel in weekParent.subviews {
                    if let dayLabel = weekLabel as? UILabel {
                        if dayLabel.text == "일" {
                            dayLabel.textColor = .systemRed
                        } else if dayLabel.text == "토" {
                            dayLabel.textColor = .systemBlue
                        } else {
                            dayLabel.textColor = .label
                        }
                    }
                }
            }
        }
    }
    
    func setDailySpendList() {
        prevBottomAnchorForScrollView = secondContentView.topAnchor
        for (idx, spend) in currentYearMonthDaySpends.enumerated() {
            let category = spend.category
            let dateStr = spend.dateStr
            let spendType = spend.spendType
            let amount = spend.amount.DoubleWithSeperator
            let saveType = spend.saveType
            
            let categoryLabel = CustomLabel(text: category)
            let amountLabel = CustomLabel(text: "\(saveType == .income ? "+" : "-")\(amount)원",
                                          color: saveType == .income ? .textBlue : .accent100)
            let dateLabel = CustomLabel(text: dateStr,
                                        size: 12,
                                        color: .lightColor)
            
            let editButton = UIButton()
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
            editButton.tintColor = .primary100
            editButton.addAction(UIAction{ [weak self] _ in
                guard let self = self else { return }
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let editAction = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    
                    if self.currentYearMonthSpends[idx].isUserDefault == true {
                        let alert = UIAlertController(title: "오류", message: "고정 지출 금액은 수정할 수 없습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        alertDelegate?.showAlert(controller: alert)
                        return
                    }
                    
                    editDelegate?.showEditPage(controller: EditSpendViewController(), selectedSpend: self.currentYearMonthSpends[idx])
                }
                let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    let copiedSpend = self.currentYearMonthSpends[idx]
                    
                    if copiedSpend.isUserDefault == true {
                        let alert = UIAlertController(title: "오류", message: "고정 지출 금액은 삭제할 수 없습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        alertDelegate?.showAlert(controller: alert)
                        return
                    }
                    
                    dataManager.removeSpend(removeSpend: copiedSpend)
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                alertController.addAction(editAction)
                alertController.addAction(deleteAction)
                alertController.addAction(cancelAction)
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self
                    popoverController.sourceRect = CGRect(x: self.bounds.midX, y: self.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                alertDelegate?.showAlert(controller: alertController)
            }, for: .touchUpInside)
            
            let seperator = HorizontalSeparator()
            
            [categoryLabel, amountLabel, dateLabel, editButton, seperator].forEach{ secondContentView.addSubview($0) }
            
            NSLayoutConstraint.activate([
                dateLabel.topAnchor.constraint(equalTo: prevBottomAnchorForScrollView, constant: 10),
                dateLabel.leadingAnchor.constraint(equalTo: secondContentView.leadingAnchor, constant: 10),
                
                categoryLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
                categoryLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
                
                editButton.topAnchor.constraint(equalTo: prevBottomAnchorForScrollView, constant: 20),
                editButton.trailingAnchor.constraint(equalTo: secondContentView.trailingAnchor, constant: -10),
                
                amountLabel.topAnchor.constraint(equalTo: prevBottomAnchorForScrollView, constant: 20),
                amountLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -10),
                
                seperator.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
                seperator.leadingAnchor.constraint(equalTo: secondContentView.leadingAnchor, constant: 10),
                seperator.trailingAnchor.constraint(equalTo: secondContentView.trailingAnchor, constant: -10),
            ])
            
            if idx == self.currentYearMonthSpends.count - 1 {
                seperator.bottomAnchor.constraint(equalTo: secondContentView.bottomAnchor).isActive = true
                break
            }
            prevBottomAnchorForScrollView = seperator.bottomAnchor
        }
    }
    
    func loadCurrentYearMonthData(year: Int, month: Int) {
        dataManager.getCurrentYearMonthSpends(year: year, month: month)
    }
    
    func loadCurrentYearMonthDayData(year: Int, month: Int, day: Int) {
        dataManager.getCurrentYearMonthDaySpends(year: year, month: month, day: day)
    }
}

extension MainView: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
        tempSpendView.forEach{ $0.removeFromSuperview() }
        tempSpendView.removeAll()
        
        if let dateComponent = dateComponents,
            let year = dateComponent.year,
            let month = dateComponent.month,
            let day = dateComponent.day {
            
            dataManager.getCurrentYearMonthDaySpends(year: year, month: month, day: day)
            setDailySpendList()
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        let dateString = dateFormatter.string(from: date)
        let models = currentYearMonthSpends.filter { $0.dateStr == dateString }
        
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
}

extension MainView: ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel, isDeleted: Bool = false) {
        tempSpendView.forEach{ $0.removeFromSuperview() }
        tempSpendView.removeAll()
        
        dataManager.getCurrentYearMonthDaySpends(year: currentYear, month: currentMonth, day: currentDay)
        
//        reloadAfterSave = true
//        if isDeleted == false {
//            if let index = currentSpend.firstIndex(where: { $0.id == newSpend.id }) {
//                currentSpend.remove(at: index)
//            }
//            currentSpend.append(newSpend)
//            self.setSpendList()
//        } else {
//            if let index = currentSpend.firstIndex(where: { $0.id == newSpend.id }) {
//                currentSpend.remove(at: index)
//            }
//        }
//        
//        let spendDate = newSpend.dateStr.components(separatedBy: "-").map{ Int($0) }
//        
//        guard let newYear = spendDate[0],
//              let newMonth = spendDate[1],
//              let newDay = spendDate[2] else { return }
//        
//        calendarView.reloadDecorations(forDateComponents: [DateComponents(year: newYear, month: newMonth, day: newDay)], animated: true)
//        dataManager.getRecordsBy(year: newYear, month: newMonth, target: .calendar)
//        currentMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth)
//        prevMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth - 1)
//        updateSpendLabels(month: currentMonth)
    }
}
