//
//  ViewCustom.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/30.
//

import Foundation
import UIKit

extension UIViewController {
    func getAllTextFields(from view: UIView){
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                textField.backgroundColor = UIColor.init(hex: "#fafafa")
                textField.borderStyle = .none
                textField.layer.shadowOffset = CGSize(width: 0.8, height: 1.5)
                textField.layer.shadowColor = UIColor.black.cgColor
                textField.layer.shadowOpacity = 0.15
                textField.layer.shadowRadius = 1.5
                textField.layer.cornerRadius = 4.0
            }
        }
    }
    
    func shadowView(from view: UIView){
        view.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.layer.cornerRadius = 5
    }
    
    func shadowButton(from button: UIButton){
        button.layer.shadowOffset = CGSize(width: 0.8, height: 1.5)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 1.5
        button.layer.cornerRadius = 4.0
    }
}
