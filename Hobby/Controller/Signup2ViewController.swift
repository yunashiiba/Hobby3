//
//  Signup2ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/25.
//

import UIKit

class Signup2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var AgePickerView : UIPickerView!
    @IBOutlet weak var CountryPickerView : UIPickerView!
    @IBOutlet weak var miniview: UIView!
    
    var buttons : [UIButton] = []
    var results : [String] = []
    
    let countries = ["日本","中国","韓国","アメリカ","アジア","中東","欧州","アフリカ","北米","中南米","大洋州"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowButton(from: nextButton)
        shadowButton(from: backButton)
        miniview.layer.cornerRadius = 5

        AgePickerView.delegate = self
        AgePickerView.dataSource = self
        AgePickerView.tag = 1
        CountryPickerView.delegate = self
        CountryPickerView.dataSource = self
        CountryPickerView.tag = 2
        
        AgePickerView.selectRow(Int(results[4])!, inComponent: 0, animated: false)
        CountryPickerView.selectRow(Int(results[5])!, inComponent: 0, animated: false)
        let button = self.view.viewWithTag(Int(results[3])! + 1) as! UIButton
        button.isSelected = true
        button.backgroundColor = UIColor(hex: "#CBECFF")
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            button.addTarget(self, action: #selector(Signup2ViewController.tap), for: .touchUpInside)
            buttons.append(button)
            shadowButton(from: button)
        }
    }
    
    @objc func tap(_ sender:UIButton) {
        if !sender.isSelected {
            buttons.forEach({element in
                element.isSelected = false
                element.backgroundColor = UIColor(hex: "#EDEFEE")
            })
            results[3] = "\(sender.tag - 1)"
        }
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor(hex: "#CBECFF") : UIColor(hex: "#EDEFEE")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return 11
        } else{
            return countries.count
        }
    }
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return "\(row)0代"
        } else {
            return countries[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if pickerView.tag == 1 {
            results[4] = "\(row)"
        } else {
            results[5] = "\(row)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to Signup3" {
            let view2 = segue.destination as! Signup3ViewController
            view2.results = results
        } else if segue.identifier == "unwindToSignup1" {
            if let destinationVC = segue.destination as? SignupViewController {
                destinationVC.results = results
            }
        }
    }

    @IBAction func back(_ sender: UIStoryboardSegue) {
        performSegue(withIdentifier: "unwindToSignup1", sender: self)
    }
    
    @IBAction func unwindToSignup2(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? Signup3ViewController {
            results = sourceVC.results
            AgePickerView.selectRow(Int(results[4])!, inComponent: 0, animated: false)
            CountryPickerView.selectRow(Int(results[5])!, inComponent: 0, animated: false)
            let button = self.view.viewWithTag(Int(results[3])! + 1) as! UIButton
            button.isSelected = true
            button.backgroundColor = UIColor(hex: "#CBECFF")
        }
    }
    


}
