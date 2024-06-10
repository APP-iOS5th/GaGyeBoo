import UIKit
import CoreData
import Combine

class SpendDataManager {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let fetchRequest: NSFetchRequest<GaGyeBoo> = GaGyeBoo.fetchRequest()
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
            print("Could not save. \(error.localizedDescription)")
        }
    }
    
    func getAllSpends() {
        var spendRecords: [GaGyeBooModel] = []
        do {
            let allSpends = try context.fetch(fetchRequest)
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
            print("Load Records Error >> \(error.localizedDescription)")
        }
        allSpends = spendRecords
    }
    
    func getRecordsBy(year: Int, month: Int? = nil, day: Int? = nil) {
        let calendar = Calendar.current
        
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1

        var endComponents = DateComponents()
        endComponents.year = year + 1
        endComponents.month = 1
        endComponents.day = 1
        
        if let month = month {
            startComponents.month = month
            endComponents.month = month + 1
            if let day = day {
                startComponents.day = day
                endComponents.month = month
                endComponents.year = year
                endComponents.day = day + 1
            }
        }
        print(startComponents, endComponents)
        if let startDate = calendar.date(from: startComponents), let endDate = calendar.date(from: endComponents) {
            let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
            fetchRequest.predicate = predicate
            do {
                let spends = try context.fetch(fetchRequest)
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
                    print(spendList.count)
                    spendsForDetailList = spendList
                } else {
                    spendsForDetailList = []
                }
            } catch {
                print("error in find Data >> \(error.localizedDescription)")
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
