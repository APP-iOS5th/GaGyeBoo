import UIKit
import Combine

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    
    var selectedDate: Date?
    private var cancellable: Cancellable?
    
    private let mainView = MainView()
    private let dataManager = SpendDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.alertDelegate = self
        mainView.editDelegate = self
            
        setSelectedDateSubscriber()
        setNavigationComponents()
        self.view = mainView
    }
    
    func setSelectedDateSubscriber() {
        cancellable?.cancel()
        cancellable = self.mainView.$selectedDate.sink { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
        }
    }
    
    func setNavigationComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(toAddPage))
        navigationItem.rightBarButtonItem?.tintColor = .primary100
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func toAddPage() {
        let addPageController = AddViewController()
        addPageController.calendarDelegate = self
        addPageController.selectedDate = selectedDate
        
        present(UINavigationController(rootViewController: addPageController), animated: true)
    }
}

extension MainViewController: ShowAlertDelegate {
    func showAlert(controller: UIAlertController) {
        self.present(controller, animated: true, completion: nil)
    }
}

extension MainViewController: ShowEditDelegate {
    func showEditPage(controller: UIViewController, selectedSpend: GaGyeBooModel) {
        if let editView = controller as? EditSpendViewController {
            editView.calendarDelegate = self
            editView.selectedSpend = selectedSpend
            
            self.present(editView, animated: true)
        }
    }
}

extension MainViewController: ReloadCalendarDelegate {
    func reloadCalendar(newSpend: GaGyeBooModel, isDeleted: Bool) {
        let dateArr = newSpend.dateStr.components(separatedBy: "-").map{ Int($0)! }
        mainView.loadCurrentYearMonthData(year: dateArr[0], month: dateArr[1])
        mainView.loadCurrentYearMonthDayData(year: dateArr[0], month: dateArr[1], day: dateArr[2])
    }
}

/*
MARK: 혹시 몰라서 남겨둠
private lazy var currentMonthSpendLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)

    return label
}()

private lazy var prevMonthSpendLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    label.textColor = .lightGray

    return label
}()
 
private func updateSpendLabels(month: Int) {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    guard let prevMonthSpend = prevMonthSpend, let currentMonthSpend = currentMonthSpend else {
        currentMonthSpendLabel.text = ""
        prevMonthSpendLabel.text = "\(month)월 혹은 지난달에 지출내역이 없습니다."
        return
    }
    
    let spendLabelText = numberFormatter.string(from: NSNumber(value: abs(currentMonthSpend))) ?? ""
    currentMonthSpendLabel.text = "\(month)월 사용금액: \(spendLabelText)원"
    let comparePrevAndCurrentMonthSpend = Int(prevMonthSpend - currentMonthSpend) / 10000
    let spendStr: String
    if comparePrevAndCurrentMonthSpend < 0 {
        spendStr = "지난달보다 약 \(-comparePrevAndCurrentMonthSpend)만원 더 썼어요."
    } else {
        spendStr = "지난달보다 약 \(comparePrevAndCurrentMonthSpend)만원 덜 썼어요."
    }
    prevMonthSpendLabel.text = spendStr
}
 */
