import Foundation

struct MonthlyStatistics {
    let month: String
    let totalIncome: Double
    let totalExpense: Double
    
    init(month: String, totalIncome: Double, totalExpense: Double) {
        self.month = month
        self.totalIncome = totalIncome
        self.totalExpense = totalExpense
    }
    
    init(from statisticsData: [StatisticsData], month: String) {
        self.month = month
        let filteredData = statisticsData.filter { $0.month?.contains(month) == true }
        self.totalIncome = filteredData.map { $0.totalIncome }.reduce(0, +)
        self.totalExpense = filteredData.map { $0.totalExpense }.reduce(0, +)
    }
}
