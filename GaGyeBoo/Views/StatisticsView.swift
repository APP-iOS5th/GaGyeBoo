import UIKit
import DGCharts

class StatisticsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private let dataManager = DataManager()
    private let spendDataManager = SpendDataManager()
    private var monthlySummaries: [MonthlySummary] = []
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["수입", "지출"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.backgroundColor = .systemGray6
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: monthData)
        
        let maxLabelCount = max(incomeData.count, expenseData.count)
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
    
    var monthData: [String] = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    var incomeData: [Double] = [1000, 1200, 1300, 1100, 1050, 1150, 1250, 1230, 1280, 1150, 1200, 1250]
    var expenseData: [Double] = [800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300, 1350]
    
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
        spendDataManager.loadSpends()
        updateMonthlySummaries()
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
        updateBarChartData()
        tableView.reloadData()
    }
    
    private func updateMonthlySummaries() {
        var summaries: [String: MonthlySummary] = [:]
        
        for spend in spendDataManager.allSpends {
            let month = DateFormatter.localizedString(from: spend.date, dateStyle: .short, timeStyle: .none)
            
            if summaries[month] == nil {
                summaries[month] = MonthlySummary(month: month, totalIncome: 0, totalExpense: 0)
            }
            
            if spend.saveType == .income {
                summaries[month]?.totalIncome += spend.amount
            } else {
                summaries[month]?.totalExpense += spend.amount
            }
        }
        
        monthlySummaries = Array(summaries.values).sorted { $0.month < $1.month }
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
            data = monthlySummaries.map { $0.totalIncome }
            label = "수입"
        } else {
            data = monthlySummaries.map { $0.totalExpense }
            label = "지출"
        }
        barChartView.isHidden = data.isEmpty
        noDataLabel.isHidden = !data.isEmpty
        
        if !data.isEmpty {
            let chartData = createBarChartData(values: data, label: label)
            barChartView.data = chartData
            barChartView.animate(xAxisDuration: 3, yAxisDuration: 3, easingOption: .easeInOutBounce)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlySummaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsTableCell", for: indexPath) as? StatisticsTableCell else {
            fatalError("The TableView could not customCell")
        }
        let summary = monthlySummaries[indexPath.row]
        let month = summary.month
        let incomeAmount = "\(Int(summary.totalIncome))원"
        let expenseAmount = "\(Int(summary.totalExpense))원"
        
        cell.configure(with: month, incomeAmount: incomeAmount, expenseAmount: expenseAmount)
        
        return cell
    }
}


