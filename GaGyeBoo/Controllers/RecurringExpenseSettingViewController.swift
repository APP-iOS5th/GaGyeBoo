//
//  RecurringExpenseSettingViewController.swift
//  GaGyeBoo
//
//  Created by Jude Song on 6/11/24.
//

import UIKit

class RecurringExpenseSettingViewController: UIViewController {
    private let dataManager = SpendDataManager()
    private let expenseCategories = ["식비", "교통", "쇼핑", "문화생활", "공과금", "기타"]
    
    private let categoryHeaderLabel = UILabel()
    private let categoryScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let categoryStackView = UIStackView()
    private var selectedCategoryButton: UIButton?
    
    private let nameHeaderLabel = UILabel()
    private let nameTextField = UITextField()
    
    private let expenseHeaderLabel = UILabel()
    private let expenseTextField = UITextField()
    private let wonLabel = UILabel()
    
    private let dayHeaderLabel = UILabel()
    private let eachMonthLabel = UILabel()
    private let dayTextField = UITextField()
    private let dayPicker = UIPickerView()
    private let dayLabel = UILabel()
    
    private let saveButton = UIBarButtonItem(title: "저장", style: .done, target: nil, action: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .primary100
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseTextField.delegate = self
        setupViews()
        setupConstraints()
        
        //Retrieve the stored data from UserDefaults
        let storedCategory = UserDefaults.standard.string(forKey: "selectedCategory")
        let storedName = UserDefaults.standard.string(forKey: "expenseName")
        let storedExpense = UserDefaults.standard.integer(forKey: "expenseAmount")
        let storedDay = UserDefaults.standard.integer(forKey: "selectedDay")
        
        //뿌려주기
        if let storedCategory = storedCategory {
            for (index, categoryButton) in categoryStackView.arrangedSubviews.enumerated() {
                if let button = categoryButton as? UIButton, button.titleLabel?.text == storedCategory {
                    categoryButtonTapped(button)
                    break
                }
            }
        }
        
        nameTextField.text = storedName
        expenseTextField.text = "\(storedExpense)"
        
        if storedDay > 0 {
            dayPicker.selectRow(storedDay - 1, inComponent: 0, animated: false)
            dayTextField.text = "\(storedDay)"
        }
    }
    
    private func setupViews() {
        title = "월 고정 지출 설정"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = saveButton
        saveButton.target = self
        saveButton.action = #selector(saveButtonTapped)
        
        categoryHeaderLabel.text = "분류"
        categoryHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        categoryHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryHeaderLabel)
        
        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fillProportionally
        categoryStackView.alignment = .center
        categoryStackView.spacing = 10
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(categoryStackView)
        
        for category in expenseCategories {
            let categoryButton = CategoryButton(type: .system)
            categoryButton.setTitle(category, for: .normal)
            categoryButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            categoryButton.configuration?.cornerStyle = .medium
            categoryButton.configuration = .bordered()
            categoryButton.setTitleColor(.label, for: .normal)
            categoryButton.setTitleColor(.white, for: .selected)
            categoryButton.backgroundColor = .systemBackground
            categoryButton.layer.cornerRadius = 8
            categoryButton.clipsToBounds = true
            categoryButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            categoryButton.setContentHuggingPriority(.required, for: .horizontal)
            categoryButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            categoryStackView.addArrangedSubview(categoryButton)
        }
        
        view.addSubview(categoryScrollView)
        
        nameHeaderLabel.text = "내역"
        nameHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameHeaderLabel)
        
        nameTextField.placeholder = "지출 내역을 입력하세요."
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        expenseHeaderLabel.text = "금액"
        expenseHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        expenseHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(expenseHeaderLabel)
        
        expenseTextField.placeholder = "지출 금액을 입력하세요."
        expenseTextField.keyboardType = .numberPad
        expenseTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(expenseTextField)
        
        wonLabel.text = "원"
        wonLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wonLabel)
        
        dayHeaderLabel.text = "반복 일자"
        dayHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dayHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dayHeaderLabel)
        
        eachMonthLabel.text = "매월"
        eachMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eachMonthLabel)
        
        dayTextField.placeholder = "반복일을 선택하세요."
        dayTextField.translatesAutoresizingMaskIntoConstraints = false
        dayTextField.inputView = dayPicker
        dayTextField.adjustsFontSizeToFitWidth = true
        dayTextField.minimumFontSize = 12
        dayTextField.textAlignment = .center
        view.addSubview(dayTextField)
        
        dayLabel.text = "일"
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dayLabel)
        
        dayPicker.delegate = self
        dayPicker.dataSource = self
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            categoryScrollView.topAnchor.constraint(equalTo: categoryHeaderLabel.bottomAnchor, constant: 8),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -16),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            
            nameHeaderLabel.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 24),
            nameHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameTextField.topAnchor.constraint(equalTo: nameHeaderLabel.bottomAnchor, constant: 12),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            expenseHeaderLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            expenseHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            expenseTextField.topAnchor.constraint(equalTo: expenseHeaderLabel.bottomAnchor, constant: 12),
            expenseTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            wonLabel.centerYAnchor.constraint(equalTo: expenseTextField.centerYAnchor),
            wonLabel.leadingAnchor.constraint(equalTo: expenseTextField.trailingAnchor, constant: 12),
            
            dayHeaderLabel.topAnchor.constraint(equalTo: expenseTextField.bottomAnchor, constant: 24),
            dayHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            eachMonthLabel.topAnchor.constraint(equalTo: dayHeaderLabel.bottomAnchor, constant: 8),
            eachMonthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eachMonthLabel.widthAnchor.constraint(equalToConstant: 40),
            
            dayTextField.centerYAnchor.constraint(equalTo: eachMonthLabel.centerYAnchor),
            dayTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dayTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            dayLabel.centerYAnchor.constraint(equalTo: dayTextField.centerYAnchor),
//            dayLabel.leadingAnchor.constraint(equalTo: dayTextField.trailingAnchor, constant: 8),
            dayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            
        ])
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        selectedCategoryButton?.isSelected = false
        selectedCategoryButton?.backgroundColor = .systemBackground
        selectedCategoryButton?.setTitleColor(.label, for: .normal)
        selectedCategoryButton?.setTitleColor(.label, for: .selected)
        
        sender.isSelected = true
        sender.backgroundColor = .primary100
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.white, for: .selected)
        
        selectedCategoryButton = sender
        print("Selected category: \(sender.titleLabel?.text ?? "")")
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "오류", message: "고정 지출 내역을 입력해 주세요.")
            return
        }
        
        guard let expenseText = expenseTextField.text, !expenseText.isEmpty else {
            showAlert(title: "오류", message: "지출 금액을 입력해 주세요.")
            return
        }
        
        let expense = Int(expenseText) ?? 0
        let selectedCategory = selectedCategoryButton?.titleLabel?.text ?? ""
        let selectedDay = dayPicker.selectedRow(inComponent: 0) + 1
        
        if UserDefaults.standard.integer(forKey: "selectedDay") > 0 {
            dataManager.removeDefaultSpends()
        }
        
        // Save the recurring expense data
        UserDefaults.standard.set(selectedCategory, forKey: "selectedCategory")
        UserDefaults.standard.set(name, forKey: "expenseName")
        UserDefaults.standard.set(expense, forKey: "expenseAmount")
        UserDefaults.standard.set(selectedDay, forKey: "selectedDay")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        for year in 2024...2026 {
            for month in 1...12 {
                let dateStr = "\(2024)-\(month)-\(selectedDay)"
                if let date = formatter.date(from: dateStr) {
                    dataManager.saveSpend(newSpend: GaGyeBooModel(date: date, saveType: .expense, category: selectedCategory, spendType: name, amount: Double(expense)), isUserDefault: true)
                }
            }
//        }
        
        print("Saved recurring expense: \(name), \(expense) for category: \(selectedCategory) on day: \(selectedDay)")
        
        // Navigate back to the previous view controller
        navigationController?.popViewController(animated: true)
        
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RecurringExpenseSettingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }
}

extension RecurringExpenseSettingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == expenseTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}

extension RecurringExpenseSettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDay = row + 1
        
        if selectedDay >= 29 {
            let currentDate = Date()
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
            let range = Calendar.current.range(of: .day, in: .month, for: nextMonth)
            let lastDayOfNextMonth = range?.count ?? 0
            
            if Calendar.current.component(.month, from: nextMonth) == 2 {
                let year = Calendar.current.component(.year, from: nextMonth)
                let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
                let lastDayOfFebruary = isLeapYear ? 29 : 28
                
                dayTextField.text = "\(min(selectedDay, lastDayOfFebruary))"
            } else {
                dayTextField.text = "\(min(selectedDay, lastDayOfNextMonth))"
            }
        } else {
            dayTextField.text = "\(selectedDay)"
        }
        
        dayTextField.sizeToFit()
        dayTextField.resignFirstResponder()
    }
}
 
