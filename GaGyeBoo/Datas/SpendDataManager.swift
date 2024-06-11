import UIKit
import CoreData
import Combine

class SpendDataManager {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let gaGyeBooFetchRequest: NSFetchRequest<GaGyeBoo> = GaGyeBoo.fetchRequest()
    private let monthlySpendFetchRequest: NSFetchRequest<MonthlyRecord> = MonthlyRecord.fetchRequest()
    @Published var allSpends: [GaGyeBooModel] = []
    @Published var spendsForDetailList: [GaGyeBooModel] = []
    var cancellable: Cancellable?
    
    func saveSpend(newSpend: GaGyeBooModel) {
        if let entity = NSEntityDescription.entity(forEntityName: "GaGyeBoo", in: context) {
            let spend = NSManagedObject(entity: entity, insertInto: context)
            spend.setValue(newSpend.date, forKey: "date")
            spend.setValue(newSpend.saveType.rawValue, forKey: "saveType")
            spend.setValue(newSpend.category, forKey: "category")
            spend.setValue(newSpend.spendType, forKey: "spendType")
            spend.setValue(newSpend.amount, forKey: "amount")
        }
        
        do {
            try context.save()
        } catch let error {
            print("error in SpendDataManager saveSpend() >> \(error.localizedDescription)")
        }
    }
    
    func saveMonthlyRecord(newSpend: GaGyeBooModel) {
        if newSpend.saveType == .expense {
            let newSpendDate = newSpend.dateStr.components(separatedBy: "-")
            let searchDateStr = "\(newSpendDate[0])-\(newSpendDate[1])"
            monthlySpendFetchRequest.predicate = NSPredicate(format: "date CONTAINS %@", searchDateStr)
            
            do {
                let spends = try context.fetch(monthlySpendFetchRequest)
//                var totalSpend: Double = newSpend.saveType == .income ? newSpend.amount : -newSpend.amount
                var totalSpend: Double = newSpend.amount
                if let updateEntity = spends.first {
                    for spend in spends {
                        totalSpend += spend.value(forKey: "totalSpend") as! Double
                    }
                    updateEntity.setValue(totalSpend, forKey: "totalSpend")
                } else {
                    if let entity = NSEntityDescription.entity(forEntityName: "MonthlyRecord", in: context) {
                        let spend = NSManagedObject(entity: entity, insertInto: context)
                        spend.setValue(newSpend.amount, forKey: "totalSpend")
                        spend.setValue(searchDateStr, forKey: "date")
                    }
                }
                
                try context.save()
            } catch {
                print("error in SpendDataManager saveMonthlyRecord() >> \(error.localizedDescription)")
            }
        }
    }
    
    func getPrevSpend(year: Int, month: Int) -> Double? {
        var tempYear: Int = year
        var tempMonth: Int = month
        if tempMonth <= 0 {
            tempYear -= 1
            tempMonth = 12
        }
        
        let searchDate = "\(tempYear)-\(String(tempMonth).count == 1 ? "0\(tempMonth)" : "\(tempMonth)")"
        monthlySpendFetchRequest.predicate = NSPredicate(format: "date CONTAINS %@", searchDate)
        
        var totalSpend: Double?
        do {
            let monthlyRecord = try context.fetch(monthlySpendFetchRequest)
            if let record = monthlyRecord.first {
                totalSpend = record.totalSpend
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
    
    func getRecordsBy(year: Int, month: Int? = nil, day: Int? = nil) {
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
                    spendsForDetailList = spendList
                } else {
                    spendsForDetailList = []
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
