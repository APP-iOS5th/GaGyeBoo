//
//  AddViewController.swift
//  GaGyeBoo
//
//  Created by MadCow on 2024/6/4.
//

import UIKit

class AddViewController: UIViewController {
    
    let datePicker: UIDatePicker = {
        let cal = UIDatePicker()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.datePickerMode = .date
        cal.preferredDatePickerStyle = .inline
        cal.locale = Locale(identifier: "ko_KR")
        return cal
    }()
    
    let segmentedControl: UISegmentedControl = {
        let type = UISegmentedControl(items: ["수입", "지출"])
        type.translatesAutoresizingMaskIntoConstraints = false
        type.selectedSegmentIndex = 1
        
        type.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return type
    }()
    
    let textFieldContainer: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let moneyTextField: UIStackView = {
        let moneyStackView = UIStackView()
        moneyStackView.axis = .horizontal
        moneyStackView.alignment = .fill
        moneyStackView.distribution = .fill
        moneyStackView.spacing = 8
        
        let labelComponent = UILabel()
        labelComponent.text = "금액: "
        
        let moneyField = UITextField()
        moneyField.placeholder = "금액............?"
        moneyField.borderStyle = .roundedRect
        
        moneyField.addTarget(self, action: #selector(moneyTextChanged(moneyField:)), for: .editingChanged)
        
        moneyStackView.addArrangedSubview(labelComponent)
        moneyStackView.addArrangedSubview(moneyField)
        
        return moneyStackView
    }()
    
    let categoryField: UIStackView = {
        let categoryStackView = UIStackView()
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .fill
        categoryStackView.distribution = .fill
        categoryStackView.spacing = 8
        
        let labelComponent = UILabel()
        labelComponent.text = "카테고리: "
        
        let iconComponent = UITextField()
        iconComponent.placeholder = "카테고리?"
        iconComponent.borderStyle = .roundedRect
        
        categoryStackView.addArrangedSubview(labelComponent)
        categoryStackView.addArrangedSubview(iconComponent)
        
        return categoryStackView
    }()
    
    let contentsField: UIStackView = {
        let contentsStackView = UIStackView()
        contentsStackView.axis = .horizontal
        contentsStackView.alignment = .fill
        contentsStackView.distribution = .fill
        contentsStackView.spacing = 8
        
        let labelComponent = UILabel()
        labelComponent.text = "내용: "
        
        let contents = UITextField()
        contents.placeholder = "세부 사항을 입력하세요."
        contents.borderStyle = .roundedRect
        
        contentsStackView.addArrangedSubview(labelComponent)
        contentsStackView.addArrangedSubview(contents)
        
        return contentsStackView
    }()
    
    let photoField: UIStackView = {
        let photoStackView = UIStackView()
        photoStackView.axis = .horizontal
        photoStackView.alignment = .fill
        photoStackView.distribution = .fill
        photoStackView.spacing = 8
        
        let labelComponent = UILabel()
        labelComponent.text = "사진: "
        
        let photo = UITextField()
        photo.placeholder = "사진 추가 하는 기능.."
        photo.borderStyle = .roundedRect
        
        photoStackView.addArrangedSubview(labelComponent)
        photoStackView.addArrangedSubview(photo)
        
        return photoStackView
    }()
    
    var saveButton: UIButton = {
       let button = UIButton()
        button.setTitle("저장", for: .normal)
        var config = UIButton.Configuration.filled()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return outgoing
        }
        button.configuration = config
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "지출"
        view.backgroundColor = .white
        
        view.addSubview(segmentedControl)
        view.addSubview(datePicker)
        
        textFieldContainer.addArrangedSubview(moneyTextField)
        textFieldContainer.addArrangedSubview(categoryField)
        textFieldContainer.addArrangedSubview(contentsField)
        textFieldContainer.addArrangedSubview(photoField)
        textFieldContainer.addArrangedSubview(saveButton)
        view.addSubview(textFieldContainer)
        
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveItem), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            segmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),
            
            datePicker.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: segmentedControl.rightAnchor),
            datePicker.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 3),
            
            textFieldContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            textFieldContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            textFieldContainer.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 5)
        ])
    }
    
    //MARK: Methods
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            navigationItem.title = "수입"
        case 1:
            navigationItem.title = "지출"
        default:
            break
        }
    }
    
    @objc func moneyTextChanged(moneyField: UITextField) {
        updateSaveButtonState()
    }
    
    @objc private func saveItem() {
        guard let money = (moneyTextField.arrangedSubviews[1] as? UITextField)?.text, !money.isEmpty,
        let category = (categoryField.arrangedSubviews[1] as? UITextField)?.text, !category.isEmpty
        else {
            return
        }
        dismiss(animated: true)
    }
    
    func updateSaveButtonState() {
        guard let money = (moneyTextField.arrangedSubviews[1] as? UITextField)?.text, !money.isEmpty,
        let category = (categoryField.arrangedSubviews[1] as? UITextField)?.text, !category.isEmpty
        else {
            saveButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
    }
    
}
