//
//  AddViewController.swift
//  GaGyeBoo
//
//  Created by MadCow on 2024/6/4.
//

import UIKit

class AddViewController: UIViewController {
    
    let spendDataManager: SpendDataManager = SpendDataManager()
    
    let datePicker: UIDatePicker = {
        let cal = UIDatePicker()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.datePickerMode = .date
        cal.preferredDatePickerStyle = .inline
        cal.locale = Locale(identifier: "ko_KR")
        cal.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
//        cal.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        return cal
    }()
    
    //MARK: SegmentControll custom
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        
        segment.selectedSegmentTintColor = .clear
        
        //배경색 제거
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        //구분 라인 제거
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segment.insertSegment(withTitle: "수입", at: 0, animated: true)
        segment.insertSegment(withTitle: "지출", at: 1, animated: true)
        
        segment.selectedSegmentIndex = 0
        
        // 미선택 폰트
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ], for: .normal)
        
        //선택 폰트
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.systemFill,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ], for: .selected)
        
        segment.addTarget(self, action: #selector(changeSegmentedControlLinePosition), for: .valueChanged)
        
        segment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private lazy var underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 움직일 underLineView의 leadingAnchor 따로 작성
    private lazy var leadingDistance: NSLayoutConstraint = {
        return underLineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor)
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
        moneyField.placeholder = "금액을 입력하세요."
        moneyField.borderStyle = .roundedRect
        moneyField.translatesAutoresizingMaskIntoConstraints = false
        moneyField.widthAnchor.constraint(equalToConstant: 310).isActive = true
        moneyField.keyboardType = .numberPad
        
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
        labelComponent.text = "분류: "
        
        let category = UITextField()
        category.placeholder = "카테고리"
        category.borderStyle = .roundedRect
        category.translatesAutoresizingMaskIntoConstraints = false
        category.widthAnchor.constraint(equalToConstant: 310).isActive = true
        
        category.addTarget(self, action: #selector(categoryTextChanged(categoryField:)), for: .editingChanged)
        
        categoryStackView.addArrangedSubview(labelComponent)
        categoryStackView.addArrangedSubview(category)
        
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
        contents.translatesAutoresizingMaskIntoConstraints = false
        contents.widthAnchor.constraint(equalToConstant: 310).isActive = true
        
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
        photo.placeholder = "사진 추가 하는 기능"
        photo.borderStyle = .roundedRect
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.widthAnchor.constraint(equalToConstant: 310).isActive = true
        
        photoStackView.addArrangedSubview(labelComponent)
        photoStackView.addArrangedSubview(photo)
        
        return photoStackView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        var config = UIButton.Configuration.filled()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return outgoing
        }
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        return button
    }()
    
    lazy var keyBoardTapGesture: UITapGestureRecognizer = { let gesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialValues()
        view.backgroundColor = .white
        
        view.addSubview(segmentControl)
        view.addSubview(underLineView)
        view.addSubview(datePicker)
        
        textFieldContainer.addArrangedSubview(moneyTextField)
        textFieldContainer.addArrangedSubview(categoryField)
        textFieldContainer.addArrangedSubview(contentsField)
        textFieldContainer.addArrangedSubview(photoField)
        view.addSubview(textFieldContainer)
        view.addSubview(saveButton)
        
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveItem), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            segmentControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            segmentControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            segmentControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            segmentControl.heightAnchor.constraint(equalToConstant: 30),
            
            underLineView.bottomAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 5),
            leadingDistance,
            underLineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments)),
            
            datePicker.leftAnchor.constraint(equalTo: segmentControl.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: segmentControl.rightAnchor),
            datePicker.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 3),
            
            textFieldContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            textFieldContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            textFieldContainer.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 5),
            
            saveButton.topAnchor.constraint(equalTo: photoField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
    }
    
    //MARK: Methods
    
    // navigation 타이틀 초기화
    private func setupInitialValues() {
        segmentControl.selectedSegmentIndex = 0
        changeSegmentedControlLinePosition()
        
        navigationItem.title = "수입"
    }
    
    // datePikcer
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        print("Selected date: \(datePicker.date)")
    }
    
    @objc private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(segmentControl.selectedSegmentIndex)
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.leadingDistance.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
    }
    
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
    
    @objc func categoryTextChanged(categoryField: UITextField) {
        updateSaveButtonState()
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
    
    @objc private func saveItem() {
        guard let moneyText = (moneyTextField.arrangedSubviews[1] as? UITextField)?.text, !moneyText.isEmpty,
              let amount = Double(moneyText),
              let category = (categoryField.arrangedSubviews[1] as? UITextField)?.text, !category.isEmpty
        else {
            return
        }
        
        let date = datePicker.date
        let saveType: Categories = .expense
        let spendType: String? = nil
        
        let gagyebooData = GaGyeBooModel(date: date, saveType: saveType, category: category, spendType: spendType, amount: amount)
        spendDataManager.saveSpend(newSpend: gagyebooData)
        
        dismiss(animated: true)
    }
    
    //MARK: KeyBoardTapGesture
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        view.addGestureRecognizer(keyBoardTapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(keyBoardTapGesture)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func tapHandler(_sender: UIView) {
        (moneyTextField.arrangedSubviews[1] as? UITextField)?.resignFirstResponder()
        (categoryField.arrangedSubviews[1] as? UITextField)?.resignFirstResponder()
        (contentsField.arrangedSubviews[1] as?
         UITextField)?.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("keyboardup")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("keyboard down")
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

