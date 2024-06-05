import UIKit
import Charts
import DGCharts

class StatisticsView: UIView {
    
    lazy var segmentedControl: UISegmentedControl = {
        segmentedControl = UISegmentedControl(items: ["수입", "지출"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    lazy var barChartView: BarChartView = {
        let barChartView = BarChartView()
        barChartView.backgroundColor = .systemBrown
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: monthData)
        
        let maxLabelCount = max(incomeData.count, expenseData.count)
        barChartView.xAxis.setLabelCount(maxLabelCount, force: false)
        barChartView.doubleTapToZoomEnabled = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false
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
        addSubview(barChartView)
        addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            barChartView.centerXAnchor.constraint(equalTo: centerXAnchor),
            barChartView.centerYAnchor.constraint(equalTo: centerYAnchor),
            barChartView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            barChartView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            
            noDataLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
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
        
        if selectedIndex == 0 {
            data = incomeData
            label = "수입"
        } else {
            data = expenseData
            label = "지출"
        }
        
        if data.isEmpty {
            barChartView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            barChartView.isHidden = false
            noDataLabel.isHidden = true
            
            let chartData = createBarChartData(values: data, label: label)
            
            barChartView.data = chartData
        }
    }
    
}
