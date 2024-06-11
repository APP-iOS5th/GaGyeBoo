//
//  RecurringExpenseSettingViewController.swift
//  GaGyeBoo
//
//  Created by Jude Song on 6/11/24.
//

import UIKit

class RecurringExpenseSettingViewController: UIViewController {
    
    private let expenseCategories = ["식비", "교통비", "쇼핑", "유흥", "기타"]
    
    private let categoryHeaderLabel = UILabel()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseTextField.delegate = self
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        title = "고정 지출 설정"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = saveButton
        saveButton.target = self
        saveButton.action = #selector(saveButtonTapped)
        
        categoryHeaderLabel.text = "카테고리"
        categoryHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        categoryHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryHeaderLabel)
        
        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fillProportionally
        categoryStackView.alignment = .center
        categoryStackView.spacing = 10
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryStackView)
        
        for category in expenseCategories {
            let categoryButton = UIButton(type: .system)
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
            categoryStackView.addArrangedSubview(categoryButton)
        }
        
        nameHeaderLabel.text = "항목"
        nameHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameHeaderLabel)
        
        nameTextField.placeholder = "지출 항목을 입력하세요."
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
            
            categoryStackView.topAnchor.constraint(equalTo: categoryHeaderLabel.bottomAnchor, constant: 8),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameHeaderLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 24),
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
            dayTextField.leadingAnchor.constraint(equalTo: eachMonthLabel.trailingAnchor, constant: 8),
            dayTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            dayLabel.centerYAnchor.constraint(equalTo: dayTextField.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: dayTextField.trailingAnchor, constant: 8),
            dayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            
        ])
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        selectedCategoryButton?.isSelected = false
        selectedCategoryButton?.backgroundColor = .systemBackground
        selectedCategoryButton?.setTitleColor(.label, for: .normal)
        selectedCategoryButton?.setTitleColor(.label, for: .selected)
        
        sender.isSelected = true
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.white, for: .selected)
        
        selectedCategoryButton = sender
        print("Selected category: \(sender.titleLabel?.text ?? "")")
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "오류", message: "고정 지출 항목을 입력해 주세요.")
            return
        }
        
        guard let expenseText = expenseTextField.text, !expenseText.isEmpty else {
            showAlert(title: "오류", message: "지출 금액을 입력해 주세요.")
            return
        }
        
        let expense = Int(expenseText) ?? 0
        let selectedCategory = selectedCategoryButton?.titleLabel?.text ?? ""
        let selectedDay = dayPicker.selectedRow(inComponent: 0) + 1
        
        // Save the recurring expense data
        print("Saved recurring expense: \(name), \(expense) for category: \(selectedCategory) on day: \(selectedDay)")
        
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

