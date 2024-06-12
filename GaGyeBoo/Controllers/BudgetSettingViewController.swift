//
//  BudgetSettingViewController.swift
//  GaGyeBoo
//
//  Created by Jude Song on 6/10/24.
//

import UIKit

class BudgetSettingViewController: UIViewController {
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let budgetSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "월 예산 설정"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let budgetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예산을 입력하세요."
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let wonLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.tintColor = .primary100
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        title = "예산 설정"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        headerView.addSubview(saveButton)
        view.addSubview(budgetSectionLabel)
        view.addSubview(budgetTextField)
        view.addSubview(wonLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            budgetSectionLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10),
            budgetSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            budgetTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            budgetTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            wonLabel.centerYAnchor.constraint(equalTo: budgetTextField.centerYAnchor),
            wonLabel.leadingAnchor.constraint(equalTo: budgetTextField.trailingAnchor, constant: 8)
        ])
    }
    
    @objc private func saveButtonTapped() {
        guard let budgetText = budgetTextField.text, !budgetText.isEmpty else {
            showAlert(title: "오류", message: "예산을 입력해 주세요.")
            return
        }
        
        let budget = Int(budgetText) ?? 0
        
        // Save the budget data
        print("Saved budget: \(budget)")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
