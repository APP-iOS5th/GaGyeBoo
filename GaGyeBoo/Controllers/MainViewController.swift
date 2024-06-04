//
//  ViewController.swift
//  GaGyeBoo
//
//  Created by MadCow on 2024/6/3.
//

import UIKit

class MainViewController: UIViewController {
    var picker: UISegmentedControl = {
        let pk = UISegmentedControl(items: ["일간", "월간"])
        pk.translatesAutoresizingMaskIntoConstraints = false
        pk.selectedSegmentIndex = 0
        
        return pk
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setNavigationComponents()
        setSegmentPicker()
        setCalendarView()
    }
    
    func setNavigationComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(toAddPage))
    }
    
    func setSegmentPicker() {
        view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func setCalendarView() {
        
    }
    
    @objc func toAddPage() {
        // TODO: 수입/지출 내역 작성 페이지로 이동
    }
}
