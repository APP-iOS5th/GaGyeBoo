import UIKit
import DGCharts
import Combine



class StatisticsView: UIView, UITableViewDataSource, UITableViewDelegate {
    private var monthlySummaries: [MonthlyStatistics] = []
    private var filteredSummaries: [MonthlyStatistics] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "최근 6개월 통계"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["수입", "지출"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    lazy var budgetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        let recentMonths = StatisticsDataManager.shared.getRecentMonths()
        let months = recentMonths.map { ($0.components(separatedBy: "-").last ?? "") + "월" }
        let maxLabelCount = months.count
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.backgroundColor = .linen
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        barChartView.xAxis.setLabelCount(maxLabelCount, force: false)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelFont = .systemFont(ofSize: 12)
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.axisMinimum = 0.0
        
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        
        barChartView.doubleTapToZoomEnabled = false
        barChartView.legend.font = .systemFont(ofSize: 12)
        
        return barChartView
    }()
    
    lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "데이터가 없습니다."
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticsTableCell.self, forCellReuseIdentifier: StatisticsTableCell.identifier)
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSubscriptions()
        loadData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupSubscriptions()
        loadData()
    }
    
    private func setupSubscriptions() {
        StatisticsDataManager.shared.$monthlyStatistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
        
        StatisticsDataManager.shared.statisticsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        monthlySummaries = StatisticsDataManager.shared.monthlyStatistics
        updateMonthlySummaries()
        updateBarChartData()
        tableView.reloadData()
        updateBudget()
        
        if !filteredSummaries.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    private func setupView() {
        backgroundColor = .linen
        addSubview(titleLabel)
        addSubview(segmentedControl)
        addSubview(budgetLabel)
        addSubview(barChartView)
        addSubview(noDataLabel)
        addSubview(tableView)
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            budgetLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 13),
            budgetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            budgetLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            barChartView.topAnchor.constraint(equalTo: budgetLabel.bottomAnchor, constant: 10),
            barChartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            barChartView.trailingAnchor.constraint(equalTo: trailingAnchor),
            barChartView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            
            noDataLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: barChartView.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.backgroundColor = .linen
        updateBarChartData()
    }
    
    
    
    private func updateMonthlySummaries() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        if selectedIndex == 0 {
            filteredSummaries = monthlySummaries.filter { $0.totalIncome > 0 }
        } else {
            filteredSummaries = monthlySummaries.filter { $0.totalExpense > 0 }
        }
        filteredSummaries.reverse()
        
        let startIndex = max(filteredSummaries.count - 6, 0)
        filteredSummaries = Array(filteredSummaries[startIndex..<filteredSummaries.count])
        
        
        tableView.reloadData()
        
        if filteredSummaries.isEmpty {
            barChartView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            barChartView.isHidden = false
            noDataLabel.isHidden = true
        }
    }
    
    private func updateBudget() {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let monthString = String(format: "%d", month)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let storedBudget = UserDefaults.standard.integer(forKey: "budgetAmount")
            budgetLabel.text = "\(monthString)월 예상 예산: \(numberFormatter.string(from: NSNumber(value: storedBudget)) ?? "0") 원"
            budgetLabel.textColor = .text200
            budgetLabel.isHidden = false
        } else {
            let userExpenseData = UserDefaults.standard.integer(forKey: "expenseAmount")
            let userSelectedDay = UserDefaults.standard.integer(forKey: "selectedDay")
            budgetLabel.text = "매월 \(userSelectedDay)일 고정지출: \(numberFormatter.string(from: NSNumber(value: userExpenseData)) ?? "0") 원"
            budgetLabel.textColor = .accent100
            budgetLabel.isEnabled = true
        }
    }
    
    private func createBarChartData(values: [Double], label: String) -> BarChartData {
        let entries = entryData(values: values)
        let dataSet = BarChartDataSet(entries: entries, label: label)
        
        dataSet.colors = dataSet.label == "수입" ? [.text200] : [.accent100]
        dataSet.valueFont = .systemFont(ofSize: 12)
        
        let chartData = BarChartData(dataSet: dataSet)
        
        return chartData
    }
    
    private func entryData(values: [Double]) -> [BarChartDataEntry] {
        var barDataEntries: [BarChartDataEntry] = []
        
        for i in 0..<values.count {
            let barDataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            barDataEntries.append(barDataEntry)
        }
        
        return barDataEntries
    }
    
    private func updateBarChartData() {
        let recentMonths = StatisticsDataManager.shared.getRecentMonths()
        var data = Array(repeating: 0.0, count: recentMonths.count)
        let selectedIndex = segmentedControl.selectedSegmentIndex
        
        if selectedIndex == 0 {
            for summary in filteredSummaries {
                if let index = recentMonths.firstIndex(of: summary.month) {
                    data[index] = summary.totalIncome
                }
            }
        } else {
            for summary in filteredSummaries {
                if let index = recentMonths.firstIndex(of: summary.month) {
                    data[index] = summary.totalExpense
                }
            }
        }
        
        if data.allSatisfy({ $0 == 0.0 }) {
            barChartView.data = nil
            barChartView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            barChartView.isHidden = false
            noDataLabel.isHidden = true
            
            let entries = entryData(values: data)
            let dataSet = BarChartDataSet(entries: entries, label: selectedIndex == 0 ? "수입" : "지출")
            dataSet.colors = selectedIndex == 0 ? [.text200] : [.accent100]
            dataSet.valueFont = .systemFont(ofSize: 12)
            
            let chartData = BarChartData(dataSet: dataSet)
            chartData.barWidth = 0.35
            
            barChartView.data = chartData
            dataSet.valueFormatter = DefaultValueFormatter(formatter: numberFormatter)
            
            barChartView.setNeedsLayout()
            barChartView.layoutIfNeeded()
            barChartView.animate(xAxisDuration: 3, yAxisDuration: 3, easingOption: .easeInOutBounce)
        }
    }
    
    
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateMonthlySummaries()
        updateBarChartData()
        updateBudget()
        tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSummaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsTableCell", for: indexPath) as? StatisticsTableCell else {
            fatalError("The TableView could not customCell")
        }
        
        // Check if indexPath.row is outside the range of indexes in the filtered array
        guard indexPath.row < filteredSummaries.count else {
            fatalError("Index out of range")
        }
        
        let summary = filteredSummaries[indexPath.row]
        let month = summary.month.components(separatedBy: "-").last ?? ""
        let selectedIndex = segmentedControl.selectedSegmentIndex
        
        if selectedIndex == 0 {
            let incomeAmount = numberFormatter.string(from: NSNumber(value: summary.totalIncome))! + "원"
            cell.configure(with: "\(month)월", incomeAmount: incomeAmount, expenseAmount: nil)
        } else {
            let expenseAmount = numberFormatter.string(from: NSNumber(value: summary.totalExpense))! + "원"
            cell.configure(with: "\(month)월", incomeAmount: nil, expenseAmount: expenseAmount)
        }
        
        return cell
    }
}
