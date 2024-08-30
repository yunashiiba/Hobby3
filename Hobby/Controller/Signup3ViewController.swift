//
//  Signup3ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/25.
//

import UIKit

class Signup3ViewController: UIViewController, UIColorPickerViewControllerDelegate {
   
   @IBOutlet weak var colorView: UIView!
   var colorPicker = UIColorPickerViewController()
   var results : [String] = []
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var miniview: UIView!

   override func viewDidLoad() {
       super.viewDidLoad()
       
       shadowButton(from: nextButton)
       shadowButton(from: backButton)
       miniview.layer.cornerRadius = 5
       shadowView(from: colorView)

       colorPicker.delegate = self
       colorView.backgroundColor = UIColor(hex: results[9])
       colorView.isUserInteractionEnabled = true
       colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeColor)))
   }
   
   @objc func changeColor() {
       colorPicker.supportsAlpha = true
       colorPicker.selectedColor = UIColor(hex: results[9])
       present(colorPicker, animated: true)
   }

   func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
       let selectedColor = viewController.selectedColor
       colorView.backgroundColor = selectedColor
       results[9] = selectedColor.toHex()!
   }
   func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {}
    
    @IBAction func back(_ sender: UIStoryboardSegue) {
            performSegue(withIdentifier: "unwindToSignup2", sender: self)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToSignup2" {
            if let destinationVC = segue.destination as? Signup2ViewController {
                destinationVC.results = results
            }
        }else if segue.identifier == "to Signup4" {
            let view4 = segue.destination as! Signup4ViewController
            view4.results = results
        }
    }
    
    @IBAction func unwindToSignup3(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? Signup4ViewController {
            results = sourceVC.results
            colorView.backgroundColor = UIColor(hex: results[9])
        }
    }

}
