//
//  TempModel.swift
//  GaGyeBoo
//
//  Created by MadCow on 2024/6/3.
//

import Foundation

struct GaGyeBooModel {
    let id = UUID()
    let date: Date
    let saveType: String
    let category: String
    let spendType: String?
    let amount: Double
}

// let descriptions = ["점심식사", "저녁식사", "지하철", "버스", "옷", "전자제품", "영화", "커피", "술", "기타"]
enum Categories: String, CaseIterable {
    case income = "수입"
    case expense = "지출"
    
    func getCategories() -> [String] {
        switch self {
        case .income:
            return ["월급", "용돈"]
        case .expense:
            return ["식비", "교통비", "쇼핑", "유흥", "기타"]
        }
    }
}

struct MockStruct {
    private var generatedModel: [GaGyeBooModel] = []
    
    init() {
        self.generatedModel = generateSampleData()
    }
    
    private func generateSampleData() -> [GaGyeBooModel] {
        var datas: [GaGyeBooModel] = []
        let currentYear = Calendar.current.component(.year, from: Date())
        
        for month in 1...12 {
            for _ in 1...20 {
                let saveType: Categories = Categories.allCases.randomElement()!
                let category: String = saveType.getCategories().randomElement()!
                let randomAmount = Double.random(in: 1000...100000)
                var randomDay = Int.random(in: 1...28)
                if [1, 3, 5, 8, 10, 12].contains(month) {
                    randomDay = Int.random(in: 1...31)
                } else if [4, 6, 7, 9, 11].contains(month) {
                    randomDay = Int.random(in: 1...30)
                }
                
                var dateComponents = DateComponents()
                dateComponents.year = currentYear
                dateComponents.month = month
                dateComponents.day = randomDay
                let date = Calendar.current.date(from: dateComponents)!
                
                let expense = GaGyeBooModel(
                    date: date,
                    saveType: saveType.rawValue,
                    category: category,
                    spendType: saveType == .expense ? ["현금", "카드"].randomElement()! : nil,
                    amount: randomAmount
                )
                
                datas.append(expense)
            }
        }
        
        return datas.sorted{ $0.date > $1.date }
    }
    
    func getSampleDataBy(year: Int, month: Int? = nil, day: Int? = nil) -> [GaGyeBooModel] {
        return self.generatedModel.filter{ model -> Bool in
            let modelDate: Date = model.date
            var searchDateStr: String = "\(year)"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            if let month = month {
                let monthStr = String(month).count == 1 ? "0\(month)" : "\(month)"
                formatter.dateFormat = "yyyy-MM"
                searchDateStr = "\(year)-\(monthStr)"
                if let day = day {
                    let dayStr = String(day).count == 1 ? "0\(day)" : "\(day)"
                    formatter.dateFormat = "yyyy-MM-dd"
                    searchDateStr = "\(year)-\(monthStr)-\(dayStr)"
                }
            }
            let targetDateStr: String = formatter.string(from: modelDate)
            
            return targetDateStr == searchDateStr
        }
    }
}

enum StatisticsType {
    case income
    case expense
}

struct Statistics {
    let date: Date
    let amount: Double
    let type: StatisticsType
    let category: String
}

struct MonthlySummary {
    let month: String
    var totalIncome: Double
    var totalExpense: Double
}


class DataManager {
    private var statistics: [Statistics] = []
    
    func addExampleData() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 1, day: 1)
        let date = calendar.date(from: components)!
        
        statistics = [
            Statistics(date: date, amount: 10000, type: .income, category: "월급"),
            Statistics(date: date, amount: 5000, type: .expense, category: "식비")
        ]
    }
    
    func getMonthlySummaries() -> [MonthlySummary] {
        var summaries: [String: MonthlySummary] = [:]
        
        for statistic in statistics {
            let month = DateFormatter.localizedString(from: statistic.date, dateStyle: .short, timeStyle: .none)
            
            if summaries[month] == nil {
                summaries[month] = MonthlySummary(month: month, totalIncome: 0, totalExpense: 0)
            }
            if statistic.type == .income {
                summaries[month]?.totalIncome += statistic.amount
            } else {
                summaries[month]?.totalExpense += statistic.amount
            }
        }
        
        return Array(summaries.values).sorted { $0.month < $1.month }
    }
}
