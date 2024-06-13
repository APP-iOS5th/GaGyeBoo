import UIKit
import CoreData
import Combine

class SpendDataManager {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let gaGyeBooFetchRequest: NSFetchRequest<GaGyeBoo> = GaGyeBoo.fetchRequest()
    private let monthlySpendFetchRequest: NSFetchRequest<StatisticsData> = StatisticsData.fetchRequest()
    @Published var allSpends: [GaGyeBooModel] = []
    @Published var spendsForDetailList: [GaGyeBooModel] = []
    var cancellable: Cancellable?
    
    func removeDefaultSpends() {
        gaGyeBooFetchRequest.predicate = NSPredicate(format: "isUserDefault == %@", NSNumber(value: true))
        gaGyeBooFetchRequest.includesPropertyValues = false
        
        do {
            let defaultSpends = try context.fetch(gaGyeBooFetchRequest)
            if defaultSpends.count > 0 {
                for spend in defaultSpends {
                    context.delete(spend)
                }
                
                try context.save()
            }
        } catch {
            print("error in SpendDataManager in removeDefaultSpends >> \(error.localizedDescription)")
        }
    }
    
    func saveSpend(newSpend: GaGyeBooModel, isUserDefault: Bool = false) {
        if let entity = NSEntityDescription.entity(forEntityName: "GaGyeBoo", in: context) {
            let spend = NSManagedObject(entity: entity, insertInto: context)
            spend.setValue(newSpend.date, forKey: "date")
            spend.setValue(newSpend.saveType.rawValue, forKey: "saveType")
            spend.setValue(newSpend.category, forKey: "category")
            spend.setValue(newSpend.spendType, forKey: "spendType")
            spend.setValue(newSpend.amount, forKey: "amount")
            if isUserDefault == true {
                spend.setValue(true, forKey: "isUserDefault")
            }
        }
        
        do {
            try context.save()
            saveStatisticsData(newSpend: newSpend)
        } catch let error {
            print("error in SpendDataManager saveSpend() >> \(error.localizedDescription)")
        }
    }
    
    func saveStatisticsData(newSpend: GaGyeBooModel) {
        let newSpendDate = newSpend.dateStr.components(separatedBy: "-")
        let searchDateStr = "\(newSpendDate[0])-\(newSpendDate[1])"
        let saveAttribute = newSpend.saveType == .expense ? "totalExpense" : "totalIncome"
        monthlySpendFetchRequest.predicate = NSPredicate(format: "month CONTAINS %@", searchDateStr)
        
        do {
            let spends = try context.fetch(monthlySpendFetchRequest)
            var totalSpend: Double = newSpend.amount
            if let updateEntity = spends.first {
                totalSpend += updateEntity.value(forKey: saveAttribute) as! Double
                updateEntity.setValue(totalSpend, forKey: saveAttribute)
            } else {
                if let entity = NSEntityDescription.entity(forEntityName: "StatisticsData", in: context) {
                    let spend = NSManagedObject(entity: entity, insertInto: context)
                    spend.setValue(newSpend.amount, forKey: saveAttribute)
                    spend.setValue(searchDateStr, forKey: "month")
                }
            }
            
            try context.save()
        } catch {
            print("error in SpendDataManager saveMonthlyRecord() >> \(error.localizedDescription)")
        }
    }
    
    func getPrevExpense(year: Int, month: Int) -> Double? {
        var tempYear: Int = year
        var tempMonth: Int = month
        if tempMonth <= 0 {
            tempYear -= 1
            tempMonth = 12
        }
        
        let searchDate = "\(tempYear)-\(String(tempMonth).count == 1 ? "0\(tempMonth)" : "\(tempMonth)")"
        monthlySpendFetchRequest.predicate = NSPredicate(format: "month CONTAINS %@", searchDate)
        
        var totalSpend: Double?
        do {
            let monthlyRecord = try context.fetch(monthlySpendFetchRequest)
            if let record = monthlyRecord.first {
                totalSpend = record.totalExpense
            }
        } catch {
            print("error in SpendDataManager getPrevSpend() >> \(error.localizedDescription)")
        }
        
        return totalSpend
    }
    
    func getAllSpends() {
        var spendRecords: [GaGyeBooModel] = []
        do {
            let allSpends = try context.fetch(gaGyeBooFetchRequest)
            if allSpends.count > 0 {
                for spend in allSpends {
                    let date = spend.value(forKey: "date") as! Date
                    let saveType = spend.value(forKey: "saveType") as! String
                    let category = spend.value(forKey: "category") as! String
                    let spendType = spend.value(forKey: "spendType") as? String
                    let amount = spend.value(forKey: "amount") as! Double
                    if let saveTypeToEnum = Categories.allCases.filter({ $0.rawValue == saveType }).first {
                        spendRecords.append(GaGyeBooModel(date: date, saveType: saveTypeToEnum, category: category, spendType: spendType, amount: amount))
                    }
                }
            }
        } catch let error {
            print("error in SpendDataManager getAllSpends() >> \(error.localizedDescription)")
        }
        
        allSpends = spendRecords
    }
    
    func getRecordsBy(year: Int, month: Int? = nil, day: Int? = nil, target: ShowTarget) {
        let calendar = Calendar.current
        
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.hour = 0

        var endComponents = DateComponents()
        endComponents.year = year + 1
        endComponents.month = 1
        endComponents.hour = 24
        
        if let month = month {
            startComponents.month = month
            endComponents.month = month + 1
            if let day = day {
                startComponents.day = day
                endComponents.month = month
                endComponents.year = year
                endComponents.day = day
            }
        }
        
        if let startDate = calendar.date(from: startComponents), let endDate = calendar.date(from: endComponents) {
            let predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
            gaGyeBooFetchRequest.predicate = predicate
            do {
                let spends = try context.fetch(gaGyeBooFetchRequest)
                if spends.count > 0 {
                    var spendList: [GaGyeBooModel] = []
                    for spend in spends {
                        let date = spend.value(forKey: "date") as! Date
                        let saveType = spend.value(forKey: "saveType") as! String
                        let category = spend.value(forKey: "category") as! String
                        let spendType = spend.value(forKey: "spendType") as? String
                        let amount = spend.value(forKey: "amount") as! Double
                        if let saveTypeToEnum = Categories.allCases.filter({ $0.rawValue == saveType }).first {
                            spendList.append(GaGyeBooModel(date: date, saveType: saveTypeToEnum, category: category, spendType: spendType, amount: amount))
                        }
                    }
                    if target == .calendar {
                        allSpends = spendList
                    } else {
                        spendsForDetailList = spendList
                    }
                } else {
                    if target == .calendar {
                        allSpends = []
                    } else {
                        spendsForDetailList = []
                    }
                }
            } catch {
                print("error in SpendDataManager getRecordsBy() >> \(error.localizedDescription)")
            }
        }
    }
}

/*
extension String {
    var strToDate: Date? {
        get {
            let formatter = DateFormatter()
            switch self.count {
            case 4:
                formatter.dateFormat = "yyyy"
            case 5...7:
                formatter.dateFormat = "yyyy-MM"
            default:
                formatter.dateFormat = "yyyy-MM-dd"
            }
            if let formattedDate = formatter.date(from: self) {
                return formattedDate
            } else {
                return nil
            }
        }
    }
}
*/

class StatisticsDataManager {
    static let shared = StatisticsDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GaGyeBoo")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var entity: NSEntityDescription? = {
        return NSEntityDescription.entity(forEntityName: "StatisticsData", in: self.context)
    }()
    
    private init() {
        _ = fetchMonthlyStatistics()
        addMockupDataIfNeeded()
    }
    
    // Initial Data
    func loadInitialDataIfNeeded() {
        let fetchRequest: NSFetchRequest<StatisticsData> = StatisticsData.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        _ = Calendar.current.component(.month, from: Date())
        if count == 0 {
            
        }
    }
    
    // Fetch Month Data
    func fetchMonthlyStatistics() -> [MonthlyStatistics] {
        let fetchRequest: NSFetchRequest<StatisticsData> = StatisticsData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "month", ascending: true)]
        
        do {
            let statisticsData = try context.fetch(fetchRequest)
            let months = Set(statisticsData.map { $0.month ?? "" })
            return months.map { MonthlyStatistics(from: statisticsData, month: $0) }.sorted { $0.month < $1.month }
        } catch {
            print("Failed to fetch statistics data: \(error)")
            return []
        }
    }
    
    func getRecentMonths() -> [String] {
        let calendar = Calendar.current
        var recentMonths = [String]()
        var currentDate = Date()
        
        for _ in 0..<6 {
            let dateComponents = calendar.dateComponents([.year, .month], from: currentDate)
            let year = dateComponents.year!
            let month = dateComponents.month!
            let monthString = String(format: "%02d", month)
            recentMonths.append("\(year)-\(monthString)")
            
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        }
        
        return recentMonths.reversed()
    }
    
    
    // Create New Month Data
    func createMonthlyStatistics(month: String, totalIncome: Double, totalExpense: Double) {
        guard let entity = entity else {
            print("데이터가 없습니다.")
            return
        }
        
        let monthlyStatistics = NSManagedObject(entity: entity, insertInto: context)
        monthlyStatistics.setValue(month, forKey: "month")
        monthlyStatistics.setValue(totalIncome, forKey: "totalIncome")
        monthlyStatistics.setValue(totalExpense, forKey: "totalExpense")
        
        saveContext()
    }
    
    // Save Data
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addMockupDataIfNeeded() {
        let fetchRequest: NSFetchRequest<StatisticsData> = StatisticsData.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        guard count == 0 else {
            return
        }
        
        // Mock Data
//        createMonthlyStatistics(month: "2024-01", totalIncome: 1000.0, totalExpense: 500.0)
//        createMonthlyStatistics(month: "2024-02", totalIncome: 1200.0, totalExpense: 600.0)
//        createMonthlyStatistics(month: "2024-03", totalIncome: 1500.0, totalExpense: 730.0)
//        createMonthlyStatistics(month: "2024-04", totalIncome: 300.0, totalExpense: 192.0)
//        createMonthlyStatistics(month: "2024-05", totalIncome: 584.0, totalExpense: 598.0)
//        createMonthlyStatistics(month: "2024-06", totalIncome: 238.0, totalExpense: 458.0)
        saveContext()
    }
}

