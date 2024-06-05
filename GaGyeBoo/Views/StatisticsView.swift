import UIKit
import Charts
import DGCharts

class StatisticsView: UIView {
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["수입", "지출"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return control
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        barChartView.animate(xAxisDuration: 4.0, yAxisDuration: 4.0, easingOption: .easeInOutBounce)
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
    
    lazy var usageListView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    var monthData: [String] = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    var incomeData: [Double] = [1000, 1200, 1300, 1100, 1050, 1150, 1250, 1230, 1280, 1150, 1200, 1250]
    var expenseData: [Double] = [800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300, 1350]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// Mark: View
    
    private func setupView() {
        backgroundColor = .white
        addSubview(segmentedControl)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addSubview(usageListView)
        stackView.addSubview(barChartView)
        stackView.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            barChartView.topAnchor.constraint(equalTo: stackView.topAnchor),
            barChartView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            barChartView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -10),
            barChartView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
            
            noDataLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            
            usageListView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            usageListView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            usageListView.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: 20),
            usageListView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -10)
        ])
        
        updateBarChartData()
        
        
    }
    
    
    /// Mark: Method
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateBarChartData()
    }
    
    private func createBarChartData(values: [Double], label: String) -> BarChartData {
        let entries = entryData(values: values)
        let dataSet = BarChartDataSet(entries: entries, label: label)
        
        dataSet.colors = dataSet.label == "수입" ? [.blue] : [.red]
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
        var data: [Double] = []
        let selectedIndex = segmentedControl.selectedSegmentIndex
        var label = ""
        
        (data, label) = selectedIndex == 0 ? (incomeData, "수입") : (expenseData, "지출")
        barChartView.isHidden = data.isEmpty
        noDataLabel.isHidden = !data.isEmpty
        
        if !data.isEmpty {
            let chartData = createBarChartData(values: data, label: label)
            barChartView.data = chartData
            updateUsageList(data: data, label: label)
        }
        
    }
    
    private func updateUsageList(data: [Double], label: String) {
        usageListView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, value) in data.enumerated() {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let monthLabel = UILabel()
            monthLabel.text = monthData[index]
            monthLabel.font = .systemFont(ofSize: 15)
            monthLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let valueLabel = UILabel()
            valueLabel.text = "총\(label): \(Int(value))원"
            valueLabel.font = .systemFont(ofSize: 15)
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(monthLabel)
            stackView.addArrangedSubview(valueLabel)
            
            containerView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
            
            usageListView.addArrangedSubview(containerView)
        }
    }
    
}


