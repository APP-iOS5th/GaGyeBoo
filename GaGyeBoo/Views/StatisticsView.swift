import UIKit
import DGCharts

class StatisticsView: UIView, UITableViewDataSource, UITableViewDelegate {
    private var monthlySummaries: [MonthlyStatistics] = []
    private var filteredSummaries: [MonthlyStatistics] = []
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["수입", "지출"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        let months = StatisticsDataManager.shared.fetchMonthlyStatistics().map { $0.month.components(separatedBy: "-").last ?? "" }
        let maxLabelCount = months.count
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.backgroundColor = .systemGray6
        
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
        monthlySummaries = StatisticsDataManager.shared.fetchMonthlyStatistics() // 필요한 모든 월별 통계 데이터 로드
        filteredSummaries = monthlySummaries// 필터된 데이터 업데이트
        updateBarChartData()
        tableView.reloadData()
    }
    
    
    private func setupView() {
        backgroundColor = .white
        addSubview(segmentedControl)
        addSubview(barChartView)
        addSubview(noDataLabel)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
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
        updateMonthlySummaries() // 선택에 따라 필터된 데이터 업데이트
        updateBarChartData()
        tableView.reloadData()
    }
    
    private func updateMonthlySummaries() {
        monthlySummaries = StatisticsDataManager.shared.fetchMonthlyStatistics()
    }
    
    private func createBarChartData(values: [Double], label: String) -> BarChartData {
        let entries = entryData(values: values)
        let dataSet = BarChartDataSet(entries: entries, label: label)
        
        dataSet.colors = dataSet.label == "수입" ? [.blue] : [.red]
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
        var data: [Double] = []
        let selectedIndex = segmentedControl.selectedSegmentIndex
        var label = ""
        
        if selectedIndex == 0 {
            data = filteredSummaries.map { $0.totalIncome }
            label = "수입"
        } else {
            data = filteredSummaries.map { $0.totalExpense }
            label = "지출"
        }
        
        barChartView.isHidden = data.isEmpty
        noDataLabel.isHidden = !data.isEmpty
        
        if !data.isEmpty {
                let entries = entryData(values: data)
                let dataSet = BarChartDataSet(entries: entries.filter { $0.y != 0 }, label: label)
                dataSet.colors = dataSet.label == "수입" ? [.blue] : [.red]
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
        
        // indexPath.row가 필터된 배열의 인덱스 범위를 벗어나는지 확인
        guard indexPath.row < filteredSummaries.count else {
            fatalError("Index out of range")
        }
        
        let summary = filteredSummaries[indexPath.row]
        let month = summary.month.components(separatedBy: "-").last ?? ""
        let selectedIndex = segmentedControl.selectedSegmentIndex
        
        if selectedIndex == 0 {
            let incomeAmount = "\(Int(summary.totalIncome))원"
            cell.configure(with: month, incomeAmount: incomeAmount, expenseAmount: nil)
        } else {
            let expenseAmount = "\(Int(summary.totalExpense))원"
            cell.configure(with: month, incomeAmount: nil, expenseAmount: expenseAmount)
        }
        
        return cell
    }
}



