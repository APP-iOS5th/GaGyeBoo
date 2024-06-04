import UIKit

class MainViewController: UIViewController {

    let picker: UISegmentedControl = {
        let pk = UISegmentedControl(items: ["일간", "월간"])
        pk.translatesAutoresizingMaskIntoConstraints = false
        pk.selectedSegmentIndex = 0
        
        return pk
    }()
    
    let calendarView: UICalendarView = {
        var calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.wantsDateDecorations = true
        
        return calendar
    }()
    
    private let mockData = MockStruct()
    private var prevBottomAnchor: NSLayoutYAxisAnchor!
    private var currentSpend: [GaGyeBooModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setNavigationComponents()
        setSegmentPicker()
        setCalendarData()
        setCalendarView()
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
        prevBottomAnchor = picker.bottomAnchor
    }
    
    func setCalendarView() {
        calendarView.delegate = self
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 10),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func setCalendarData() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        currentSpend = mockData.getSampleDataBy(year: currentYear, month: currentMonth)
    }
    
    @objc func toAddPage() {
        // TODO: 수입/지출 내역 작성 페이지로 이동
    }
}

extension MainViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let models = currentSpend.compactMap { model in
            if model.date == dateComponents.date {
                return model
            }
            return nil
        }
        
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
                    incomeLabel.text = "\(Int(income))"

                    vStack.addArrangedSubview(incomeLabel)
                }
                if expense > 0 {
                    let expenseLabel = UILabel()
                    expenseLabel.font = UIFont.systemFont(ofSize: 9)
                    expenseLabel.textColor = .systemRed
                    expenseLabel.text = "\(Int(expense))"

                    vStack.addArrangedSubview(expenseLabel)
                }

                return vStack
            }
        }
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
    }
}
