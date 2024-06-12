import UIKit
import DGCharts

class StatisticsView: UIView, UITableViewDataSource, UITableViewDelegate {
    private var monthlySummaries: [MonthlyStatistics] = []
    private var filteredSummaries: [MonthlyStatistics] = []
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "최근 6개월 통계"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
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
    
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        let recentMonths = StatisticsDataManager.shared.getRecentMonths()
        let months = recentMonths.map { ($0.components(separatedBy: "-").last ?? "") + "월" }
        let maxLabelCount = months.count
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.backgroundColor = .bg100
        
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.setLabelCount(maxLabelCount, force: false)
        
        barChartView.xAxis.labelFont = .systemFont(ofSize: 12)
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.legend.font = .systemFont(ofSize: 15)
        
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
        loadData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        loadData()
    }
    
    private func loadData() {
        monthlySummaries = StatisticsDataManager.shared.fetchMonthlyStatistics()
        updateMonthlySummaries()
        updateBarChartData()
        tableView.reloadData()
    }
    
    
    private func setupView() {
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(segmentedControl)
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
            
            barChartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            barChartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            barChartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            barChartView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            
            noDataLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: barChartView.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        updateBarChartData()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateMonthlySummaries()
        updateBarChartData()
        tableView.reloadData()
    }
    
    private func updateMonthlySummaries() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        if selectedIndex == 0 {
            filteredSummaries = monthlySummaries.filter { $0.totalIncome > 0 }
        } else {
            filteredSummaries = monthlySummaries.filter { $0.totalExpense > 0 }
        }
    }
    
    
    private func createBarChartData(values: [Double], label: String) -> BarChartData {
        let entries = entryData(values: values)
        let dataSet = BarChartDataSet(entries: entries, label: label)
        
        dataSet.colors = dataSet.label == "수입" ? [.textBlue] : [.accent100]
        dataSet.valueFont = .systemFont(ofSize: 12)
        
        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.4
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
        
        barChartView.isHidden = data.isEmpty
        noDataLabel.isHidden = !data.isEmpty
        
        if (!data.isEmpty) {
            let entries = entryData(values: data)
            let dataSet = BarChartDataSet(entries: entries.filter { $0.y != 0 }, label: selectedIndex == 0 ? "수입" : "지출")
            dataSet.colors = selectedIndex == 0 ? [.textBlue] : [.accent100]
            dataSet.valueFont = .systemFont(ofSize: 12)
            
            let chartData = BarChartData(dataSet: dataSet)
            chartData.barWidth = 0.4
            barChartView.data = chartData
            barChartView.animate(xAxisDuration: 4, yAxisDuration: 4, easingOption: .easeInOutBounce)
        } else {
            barChartView.data = nil
        }
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
            let incomeAmount = "\(Int(summary.totalIncome))원"
            cell.configure(with: "\(month)월", incomeAmount: incomeAmount, expenseAmount: nil)
        } else {
            let expenseAmount = "\(Int(summary.totalExpense))원"
            cell.configure(with: "\(month)월", incomeAmount: nil, expenseAmount: expenseAmount)
        }
        
        return cell
    }
}
