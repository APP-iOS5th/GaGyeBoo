//
//  InquiryViewController.swift
//  GaGyeBoo
//
//  Created by Jude Song on 6/10/24.
//

import UIKit
import MessageUI

class InquiryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        openMailApp()
    }

    private func openMailApp() {
        let recipientEmail = "no47974@gmail.com"

        if let emailURL = URL(string: "mailto:\(recipientEmail)") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL)
            } else {
                showAlert(title: "오류", message: "메일 앱을 사용할 수 없습니다.")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
