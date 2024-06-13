//
//  CategoryButton.swift
//  GaGyeBoo
//
//  Created by Jude Song on 6/13/24.
//

import UIKit

class CategoryButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = .primary200
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isSelected {
            backgroundColor = .primary100
        } else {
            backgroundColor = .systemBackground
        }
    }
}
