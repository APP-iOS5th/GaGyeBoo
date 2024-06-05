import UIKit
import Charts
import DGCharts

class StatisticsView: UIView {
    
    var segmentedControl: UISegmentedControl!
    
    lazy var barChartView: BarChartView = {
       let barChartView = BarChartView()
        barChartView.backgroundColor = .brown
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        return barChartView
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
    
    private func setupView() {
        backgroundColor = .white
        
        segmentedControl = UISegmentedControl(items: ["수입", "지출"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        addSubview(segmentedControl)
        
        addSubview(barChartView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            barChartView.centerXAnchor.constraint(equalTo: centerXAnchor),
            barChartView.centerYAnchor.constraint(equalTo: centerYAnchor),
            barChartView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            barChartView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
        
        updateBarChartData()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateBarChartData()
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
        
        let entries = monthData.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: data[$0.offset]) }
        let dataSet = BarChartDataSet(entries: entries, label: label)
        let chartData = BarChartData(dataSet: dataSet)
        
        barChartView.data = chartData
    }
}
