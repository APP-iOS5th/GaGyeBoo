import UIKit
import Combine

class MainView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let secondContentView = UIView()
    private let currentMonthSpendLabel = CustomLabel(text: "", size: 20)
    private let prevMonthSpendLabel = CustomLabel(text: "", size: 12, color: .lightColor)
    
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
    
    @Published var selectedDate: Date?
    private var prevBottomAnchorForScrollView: NSLayoutYAxisAnchor!
    private var yearMonthCancellable: Cancellable?
    private var fullDateCancellable: Cancellable?
    private var calendarReloadDateCancellable: Cancellable?
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
        
        self.backgroundColor = .linen
        setSubscriber()
        configureUI()
        loadCurrentYearMonthData(year: currentYear, month: currentMonth)
        loadCurrentYearMonthDayData(year: currentYear, month: currentMonth, day: currentDay)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setSubscriber() {
        yearMonthCancellable?.cancel()
        yearMonthCancellable = dataManager.$currentYearMonthSpends.sink(receiveValue: { [weak self] spends in
            guard let self = self else { return }
            
            self.currentYearMonthSpends = spends
            if let recentSpend = spends.last {
                let recentSpendStrArr = recentSpend.dateStr.components(separatedBy: "-").map{ Int($0)! }
                self.calendarView.reloadDecorations(forDateComponents: [DateComponents(year: recentSpendStrArr[0],
                                                                                       month: recentSpendStrArr[1],
                                                                                       day: recentSpendStrArr[2])], animated: true)
            }
        })
        
        fullDateCancellable?.cancel()
        fullDateCancellable = dataManager.$currentYearMonthDaySpends.sink(receiveValue: { [weak self] spends in
            guard let self = self else { return }
            
            self.currentYearMonthDaySpends = spends
            tempSpendView.forEach{ $0.removeFromSuperview() }
            tempSpendView.removeAll()
            self.setDailySpendList()
            
            self.calendarView.reloadDecorations(forDateComponents: [DateComponents(year: currentYear, 
                                                                                   month: currentMonth,
                                                                                   day: currentDay)], animated: true)
        })
        
        calendarReloadDateCancellable?.cancel()
        calendarReloadDateCancellable = dataManager.$dateForReloadCalendar.sink(receiveValue: { [weak self] dateTuple in
            guard let self = self else { return }
            
            if dateTuple.0 > 0 && dateTuple.1 > 0 && dateTuple.1 > 0 {
                self.calendarView.reloadDecorations(forDateComponents: [DateComponents(year: dateTuple.0,
                                                                                       month: dateTuple.1,
                                                                                       day: dateTuple.2)], animated: true)
            }
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
                    
                    let copiedSpend = self.currentYearMonthDaySpends[idx]
                    if copiedSpend.isUserDefault == true {
                        let alert = UIAlertController(title: "오류", message: "고정 지출 금액은 수정할 수 없습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        alertDelegate?.showAlert(controller: alert)
                        return
                    }
                    
                    editDelegate?.showEditPage(controller: EditSpendViewController(), selectedSpend: self.currentYearMonthDaySpends[idx])
                }
                
                let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    
                    let copiedSpend = self.currentYearMonthDaySpends[idx]
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
            [categoryLabel, amountLabel, dateLabel, editButton, seperator].forEach{ tempSpendView.append($0) }
            
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
            
            if let spendType = spendType {
                let spendTypeLabel = CustomLabel(text: "-  \(spendType)")
                
                secondContentView.addSubview(spendTypeLabel)
                tempSpendView.append(spendTypeLabel)
                
                NSLayoutConstraint.activate([
                    spendTypeLabel.topAnchor.constraint(equalTo: categoryLabel.topAnchor),
                    spendTypeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 10)
                ])
            }
            
            if idx == self.currentYearMonthDaySpends.count - 1 {
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
            
            selectedDate = dateComponent.date
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
                    vStack.addArrangedSubview(CustomLabel(text: "+\(income.DoubleWithSeperator)", size: 9, color: .textBlue))
                }
                if expense > 0 {
                    vStack.addArrangedSubview(CustomLabel(text: "-\(expense.DoubleWithSeperator)", size: 9, color: .accent100))
                }
                
                return vStack
            }
        }
        return nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        if let newYear = calendarView.visibleDateComponents.year,
           let newMonth = calendarView.visibleDateComponents.month{
            loadCurrentYearMonthData(year: newYear, month: newMonth)
            
            calendarView.reloadDecorations(forDateComponents: [DateComponents(year: newYear, month: newMonth)], animated: true)
        }
    }
}
