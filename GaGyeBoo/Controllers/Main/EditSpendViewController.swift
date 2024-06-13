import UIKit

class EditSpendViewController: UIViewController {
    
    let spendDataManager: SpendDataManager = SpendDataManager()
    var selectedSpend: GaGyeBooModel?
    
    private lazy var datePicker: UIDatePicker = {
        let cal = UIDatePicker()
        cal.translatesAutoresizingMaskIntoConstraints = false
        cal.datePickerMode = .date
        cal.preferredDatePickerStyle = .inline
        cal.locale = Locale(identifier: "ko_KR")
        cal.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        cal.tintColor = .primary100
        
        return cal
    }()
    
    //MARK: SegmentControll custom
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        
        segment.insertSegment(withTitle: "수입", at: 0, animated: true)
        segment.insertSegment(withTitle: "지출", at: 1, animated: true)
        
        // 미선택 폰트
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ], for: .normal)
        
        //선택 폰트
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ], for: .selected)
        
        segment.selectedSegmentTintColor = .primary100
        segment.addTarget(self, action: #selector(changeSegmentedControlLinePosition), for: .valueChanged)
        segment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private lazy var underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 움직일 underLineView의 leadingAnchor 따로 작성
    private lazy var leadingDistance: NSLayoutConstraint = {
        return underLineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor)
    }()
    
    // 달력 밑에 사용자가 직접 입력하는 부분을 담을 컨테이너
    let textFieldContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // 금액을 입력받을 뷰
    lazy var moneyTextField: UIStackView = {
        let moneyStackView = UIStackView()
        moneyStackView.axis = .horizontal
        moneyStackView.alignment = .fill
        moneyStackView.distribution = .fill
        moneyStackView.spacing = 12
        
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
    
    //카테고리 버튼
    private var selectedCategory: String?
    private var selectedButton: UIButton?
    
    private func createCategoryButtons() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelComponent = UILabel()
        labelComponent.text = "분류: "
        stackView.addArrangedSubview(labelComponent)
        
        var categories: [String]
        if selectedSpend!.saveType == .income {
            categories = ["월급", "용돈", "기타", "추가"]
        } else {
            categories = ["식비", "교통", "쇼핑", "문화생활", "공과금", "기타", "추가"]
        }
    
        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category, for: .normal)
            var config = UIButton.Configuration.plain()
            var titleContainer = AttributeContainer()
            titleContainer.font = UIFont.boldSystemFont(ofSize: 20)
            config.attributedTitle = AttributedString(category, attributes: titleContainer)
            
            config.baseForegroundColor = .lightGray
            
            switch category {
            case "월급":
                config.image = UIImage(systemName: "dollarsign.circle")
            case "용돈":
                config.image = UIImage(systemName: "wonsign.circle")
            case "식비":
                config.image = UIImage(systemName: "fork.knife.circle")
            case "교통":
                config.image = UIImage(systemName: "car.circle")
            case "쇼핑":
                config.image = UIImage(systemName: "bag.circle")
            case "문화생활":
                config.image = UIImage(systemName: "film.circle")
            case "공과금":
                config.image = UIImage(systemName: "doc.circle")
            case "기타":
                config.image = UIImage(systemName: "ellipsis.circle")
            case "추가":
                config.image = UIImage(systemName: "plus.circle")
            default:
                config.image = UIImage(systemName: "questionmark.circle")
            }

            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 30)
            config.imagePadding = 5
            config.imagePlacement = .top
            let topButton = UIButton(configuration: config)
            button.configuration = config
            button.layer.cornerRadius = 5.0
            button.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)

            stackView.addArrangedSubview(button)
        }
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                   stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                   stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                   stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                   stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        return scrollView
    }
    
    let contentsField: UIStackView = {
        let contentsStackView = UIStackView()
        contentsStackView.axis = .horizontal
        contentsStackView.alignment = .fill
        contentsStackView.distribution = .fill
        contentsStackView.spacing = 12
        
        let labelComponent = UILabel()
        labelComponent.text = "내역: "
        
        let contents = UITextField()
        contents.placeholder = "세부 사항을 입력하세요."
        contents.borderStyle = .roundedRect
        contents.translatesAutoresizingMaskIntoConstraints = false
        contents.widthAnchor.constraint(equalToConstant: 310).isActive = true
        
        contentsStackView.addArrangedSubview(labelComponent)
        contentsStackView.addArrangedSubview(contents)
        
        return contentsStackView
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
        button.tintColor = .primary100
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        return button
    }()
    
    lazy var keyBoardTapGesture: UITapGestureRecognizer = { let gesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    var calendarDelegate: ReloadCalendarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialValues()
        view.backgroundColor = .white
        
        view.addSubview(segmentControl)
        view.addSubview(underLineView)
        view.addSubview(datePicker)
        
        textFieldContainer.addArrangedSubview(moneyTextField)
        textFieldContainer.addArrangedSubview(createCategoryButtons())
        textFieldContainer.addArrangedSubview(contentsField)
        view.addSubview(textFieldContainer)
        view.addSubview(saveButton)
        
        saveButton.isEnabled = true
        saveButton.addTarget(self, action: #selector(saveItem), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            segmentControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            segmentControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            segmentControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            segmentControl.heightAnchor.constraint(equalToConstant: 30),
            
            underLineView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5),
            underLineView.heightAnchor.constraint(equalToConstant: 5),
            leadingDistance,
            underLineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments)),
            
            datePicker.leftAnchor.constraint(equalTo: segmentControl.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: segmentControl.rightAnchor),
            datePicker.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 3),
            
            textFieldContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            textFieldContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            textFieldContainer.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 5),
            
            saveButton.topAnchor.constraint(equalTo: contentsField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        if let selectedSpend = self.selectedSpend {
            datePicker.setDate(selectedSpend.date, animated: true)
            segmentControl.selectedSegmentIndex = selectedSpend.saveType == .income ? 0 : 1
            
            (moneyTextField.arrangedSubviews[1] as? UITextField)?.text = "\(Int(selectedSpend.amount))"
            (contentsField.arrangedSubviews[1] as? UITextField)?.text = selectedSpend.spendType ?? ""
            
            let categories: [String] = segmentControl.selectedSegmentIndex == 0 ? ["월급", "용돈", "기타", "추가"] : ["식비", "교통", "쇼핑", "문화생활", "공과금", "기타", "추가"]
            
            print(categories.filter{ selectedSpend.category == $0 })
            if let category = categories.filter({ selectedSpend.category == $0 }).first {
                let buttonStack = textFieldContainer.arrangedSubviews[1].subviews[0] as! UIStackView
                for button in buttonStack.subviews {
                    if let button = button as? UIButton {
                        if let buttonConfig = button.configuration, let buttonTitle = buttonConfig.title {
                            if category == buttonTitle {
                                button.isSelected = true
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Methods
    // navigation 타이틀 초기화
    private func setupInitialValues() {
        changeSegmentedControlLinePosition()
        navigationItem.title = "새로운 가계부"
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
        textFieldContainer.arrangedSubviews.forEach { view in
            textFieldContainer.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        textFieldContainer.addArrangedSubview(moneyTextField)
        textFieldContainer.addArrangedSubview(createCategoryButtons())
        textFieldContainer.addArrangedSubview(contentsField)
        textFieldContainer.addArrangedSubview(saveButton)
        view.layoutIfNeeded()
        switch sender.selectedSegmentIndex {
        case 0:
            let saveType: Categories = .income
        case 1:
            let saveType: Categories = .expense
        default:
            break
        }
    }
    
    // 금액 입력 부분 감지
    @objc func moneyTextChanged(moneyField: UITextField) {
        updateSaveButtonState()
    }
    
    // 카테고리 버튼 선택 감지 및 선택한 값 저장
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let category = sender.title(for: .normal) else { return }
        
        if sender == selectedButton {
            sender.isSelected = false
            sender.setTitleColor(.gray, for: .normal)
            selectedButton = nil
            selectedCategory = nil
        } else {
            selectedButton?.isSelected = false
            selectedButton?.setTitleColor(.gray, for: .normal)
            
            sender.isSelected = true
            sender.setTitleColor(.label, for: .normal)
            selectedButton = sender
            selectedCategory = category
        }
        updateSaveButtonState()
        
        print("선택된 카테고리: \(category)")
    }
    
    // 저장버튼 상태 관리
    func updateSaveButtonState() {
        guard let money = (moneyTextField.arrangedSubviews[1] as? UITextField)?.text, !money.isEmpty,
              let category = selectedCategory, !category.isEmpty
        else {
            saveButton.isEnabled = false
            saveButton.tintColor = .bg200
            return
        }
        saveButton.tintColor = .primary100
        saveButton.isEnabled = true
    }
    
    // 저장버튼 기능(데이터 저장 후 코어데이터로 넘기기)
    @objc private func saveItem() {
        guard let moneyText = (moneyTextField.arrangedSubviews[1] as? UITextField)?.text, !moneyText.isEmpty,
              let amount = Double(moneyText),
              let category = selectedCategory, !category.isEmpty
        else {
            return
        }
        
        let date = datePicker.date
        let saveType: Categories = segmentControl.selectedSegmentIndex == 0 ? .income : .expense
        var spendType: String? = nil
        
        if let spendContent = (contentsField.arrangedSubviews[1] as? UITextField)?.text, !spendContent.isEmpty {
            spendType = spendContent
        }
        
        let gagyebooData = GaGyeBooModel(id: UUID(), date: date, saveType: saveType, category: category, spendType: spendType, amount: amount)
        spendDataManager.saveSpend(newSpend: gagyebooData)
        calendarDelegate?.reloadCalendar(newSpend: gagyebooData, isDeleted: false)
        
        dismiss(animated: true, completion: nil)
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

