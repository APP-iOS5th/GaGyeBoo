import UIKit
import Combine

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate, ShowAlertDelegate, ShowEditDelegate {
    
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
        calendar.locale = Locale(identifier: "ko_KR")
        
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
    private var reloadAfterSave: Bool = false
    private var selectedDate: Date = Date()
    private lazy var prevMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth - 1)
    private lazy var currentMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth)
    
    private let mainView = MainView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.alertDelegate = self
        mainView.editDelegate = self
        self.view = mainView
        
        setNavigationComponents()
//        mockData.getSampleDataBy(year: 2024).forEach{ dataManager.saveSpend(newSpend: $0) }
//        dataManager.getRecordsBy(year: currentYear, month: currentMonth, target: .calendar)
//        setDailySpendView()
        // setMonthlySpendView()
    }
    
    func showAlert(controller: UIAlertController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func showEditPage(controller: UIViewController, selectedSpend: GaGyeBooModel) {
        if let editView = controller as? EditSpendViewController {
            editView.calendarDelegate = self
            editView.selectedSpend = selectedSpend
            
            self.present(editView, animated: true)
        }
    }
    
    func setNavigationComponents() {
        // +버튼 오른쪽 아래 float?버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(toAddPage))
        navigationItem.rightBarButtonItem?.tintColor = .primary100
    }
    
    func setMonthlySpendView() {
//        tempSpendView.forEach{ $0.removeFromSuperview() }
//        tempSpendView.removeAll()
//        view.backgroundColor = .yellow
    }
    
    func setDailySpendView() {
        view.backgroundColor = .bg100
        
        setNavigationComponents()
        setScrollView()
        setPrevLabel()
        setCalendarData()
        setCalendarView()
    }
    
    func setScrollView() {
        scrollView.addSubview(contentView)
        scrollView.addSubview(secondContentView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let prevMonthSpend = prevMonthSpend, let currentMonthSpend = currentMonthSpend else {
            currentMonthSpendLabel.text = ""
            prevMonthSpendLabel.text = "\(month)월 혹은 지난달에 지출내역이 없습니다."
            return
        }
        
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
            
            let amountLabel = UILabel()
            amountLabel.translatesAutoresizingMaskIntoConstraints = false
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let amountText = numberFormatter.string(from: NSNumber(value: abs(amount))) ?? ""
            amountLabel.text = "\(saveType == .income ? "+" : "-")\(amountText)원"
            amountLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            amountLabel.textColor = saveType == .income ? .textBlue : .accent100
            
            let dateLabel = UILabel()
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.text = dateText
            dateLabel.font = UIFont.systemFont(ofSize: 12)
            dateLabel.textColor = .lightGray
            
            let editButton = UIButton()
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
            editButton.tintColor = .primary100
            editButton.tag = idx
            editButton.addAction(UIAction{ [weak self] _ in
                guard let self = self else { return }
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let action1 = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    
                    if self.spendList[idx].isUserDefault == true {
                        let alert = UIAlertController(title: "오류", message: "고정 지출 금액은 수정할 수 없습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    let editView = EditSpendViewController()
                    editView.calendarDelegate = self
                    editView.selectedSpend = self.spendList[idx]
                    
                    present(editView, animated: true)
                }
                let action2 = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    let copiedSpend = self.spendList[idx]
                    
                    if copiedSpend.isUserDefault == true {
                        let alert = UIAlertController(title: "오류", message: "고정 지출 금액은 삭제할 수 없습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    dataManager.removeSpend(removeSpend: copiedSpend)
                    reloadCalendar(newSpend: copiedSpend, isDeleted: true)
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                alertController.addAction(action1)
                alertController.addAction(action2)
                alertController.addAction(cancelAction)
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                present(alertController, animated: true, completion: nil)
            }, for: .touchUpInside)
            
            // minus.circle.fill
            
            let seperator = HorizontalSeparator()
            
            [categoryLabel, amountLabel, dateLabel, seperator, editButton].forEach{ secondContentView.addSubview($0) }
            
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
                seperator.bottomAnchor.constraint(equalTo: secondContentView.bottomAnchor)
            ])
            
            if let spendType = spendType {
                let spendTypeLabel = UILabel()
                spendTypeLabel.translatesAutoresizingMaskIntoConstraints = false
                spendTypeLabel.text = "-  \(spendType)"
                spendTypeLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                spendTypeLabel.textColor = .label
                
                tempSpendView.append(spendTypeLabel)
                secondContentView.addSubview(spendTypeLabel)
                
                NSLayoutConstraint.activate([
                    spendTypeLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
                    spendTypeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 10),
                ])
            }
            
            [categoryLabel, amountLabel, dateLabel, seperator, editButton].forEach{ tempSpendView.append($0) }
            
            prevBottomAnchorForScrollView = seperator.bottomAnchor
            if idx == spendList.count - 1 {
                seperator.bottomAnchor.constraint(equalTo: secondContentView.bottomAnchor, constant: -10).isActive = true
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func toAddPage() {
        // TODO: 수입/지출 내역 작성 페이지로 이동
        let addPageController = AddViewController()
        addPageController.calendarDelegate = self
        addPageController.selectedDate = selectedDate
        let navigationController = UINavigationController(rootViewController: addPageController)
        present(navigationController, animated: true)
    }
}

extension MainViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        var dateString = dateFormatter.string(from: date)
        if reloadAfterSave == true {
            if currentSpend.count > 0 {
                dateString = dateFormatter.string(from: currentSpend.last!.date)
            }
            reloadAfterSave = false
        }
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
            selectedDate = dateComponent.date!
            dataManager.getRecordsBy(year: year, month: month, day: day, target: .list)
            self.setSpendList()
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        if let newYear = calendarView.visibleDateComponents.year, let newMonth = calendarView.visibleDateComponents.month {
            currentMonthSpend = dataManager.getPrevExpense(year: newYear, month: newMonth)
            prevMonthSpend = dataManager.getPrevExpense(year: newYear, month: newMonth - 1)
            dataManager.getRecordsBy(year: newYear, month: newMonth, target: .calendar)
            calendarView.reloadDecorations(forDateComponents: [DateComponents(year: newYear, month: newMonth)], animated: true)
            updateSpendLabels(month: newMonth)
        }
    }
}

extension MainViewController: ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel, isDeleted: Bool = false) {
        tempSpendView.forEach{ $0.removeFromSuperview() }
        tempSpendView.removeAll()
        
        dataManager.getRecordsBy(year: currentYear, month: currentMonth, day: currentDay, target: .list)
        reloadAfterSave = true
        if isDeleted == false {
            if let index = currentSpend.firstIndex(where: { $0.id == newSpend.id }) {
                currentSpend.remove(at: index)
            }
            currentSpend.append(newSpend)
            self.setSpendList()
        } else {
            if let index = currentSpend.firstIndex(where: { $0.id == newSpend.id }) {
                currentSpend.remove(at: index)
            }
        }
        
        let spendDate = newSpend.dateStr.components(separatedBy: "-").map{ Int($0) }
        
        guard let newYear = spendDate[0], 
              let newMonth = spendDate[1],
              let newDay = spendDate[2] else { return }
        
        calendarView.reloadDecorations(forDateComponents: [DateComponents(year: newYear, month: newMonth, day: newDay)], animated: true)
        dataManager.getRecordsBy(year: newYear, month: newMonth, target: .calendar)
        currentMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth)
        prevMonthSpend = dataManager.getPrevExpense(year: currentYear, month: currentMonth - 1)
        updateSpendLabels(month: currentMonth)
    }
}
