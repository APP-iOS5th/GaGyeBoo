import Foundation

struct MonthlyStatistics {
    var month: String
    var totalIncome: Double
    var totalExpense: Double
    
    init(month: String, totalIncome: Double, totalExpense: Double) {
        self.month = month
        self.totalIncome = totalIncome
        self.totalExpense = totalExpense
    }
}
