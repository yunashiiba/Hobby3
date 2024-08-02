//
//  Mypage2ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/01.
//

import UIKit

class Mypage2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet weak var HobbyPickerView : UIPickerView!
    @IBOutlet var SearchTextfield : UITextField!
    @IBOutlet weak var alartLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    
    var datas : [String] = []
    var buttons : [UIButton] = []
    var labels : [UILabel] = []
    
    var selected = 0
    
    var hobby: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HobbyPickerView.delegate = self
        HobbyPickerView.dataSource = self
        
        fetch(url:"request_hobby") { [self] hobbies, error in
            if let error = error {
                print("Failed to fetch user IDs: \(error)")
                return
            }
            if let hobbies = hobbies as? [[Any]]{
                if (hobbies as AnyObject).count > 0{
                    var datas: [(String, Int)] = []
                    for hobby in hobbies {
                        if let hobbyName = hobby[0] as? String, let hobbyCount = hobby[1] as? Int {
                            datas.append((String(hobbyName), hobbyCount))
                        }
                    }
                    datas = datas.sorted { $0.1 > $1.1 }
                    
                    self.hobby = datas.map { $0.0 }
                    DispatchQueue.main.async { [self] in
                        HobbyPickerView.reloadAllComponents()
                    }
                    print("User IDs: \(hobbies)")
                }
            } else {
                print("No user IDs found")
            }
        }
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            let label = self.view.viewWithTag(i+3) as! UILabel
            button.addTarget(self, action: #selector(Signup3ViewController.tap), for: .touchUpInside)
            buttons.append(button)
            labels.append(label)
        }
        
        labelset()
    }
    
    @objc func tap(_ sender:UIButton) {
        datas[sender.tag + 4] = ""
        labelset()
    }
    
    func labelset(){
        let subArray = Array(datas[5...7])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        let emptyStrings = subArray.filter { $0.isEmpty }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        
        if nonEmptyStrings.count > 0{
            backButton.isEnabled = true
        }else{
            backButton.isEnabled = false
        }
        datas.replaceSubrange(5...7, with: sortedSubArray)
        
        for i in 0...2{
            labels[i].text = datas[i+5]
            if labels[i].text != "" {
                buttons[i].isHidden = false
            }else{
                buttons[i].isHidden = true
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hobby.count
    }
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return hobby[row]
    }
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        selected = row
    }
    
    @IBAction func hobbySearch(){
        if let newHobby = SearchTextfield?.text, !newHobby.isEmpty {
            if let index = self.hobby.firstIndex(of: newHobby) {
                self.HobbyPickerView.selectRow(index, inComponent: 0, animated: true)
                selected = index
                self.HobbyPickerView.reloadAllComponents()
                alartLabel.text = ""
            }else{
                alartLabel.text = "ないです"
            }
        }
    }
    
    @IBAction func hobbySerect(){
        let subArray = Array(datas[5...7])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        var emptyStrings = subArray.filter { $0.isEmpty }
        if emptyStrings.count > 0 {
            if nonEmptyStrings.contains(hobby[selected]) {
                alartLabel.text = "被ってます"
            }else{
                emptyStrings[0] = hobby[selected]
                alartLabel.text = ""
            }
        }else{
            alartLabel.text = "3つまでです"
        }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        datas.replaceSubrange(5...7, with: sortedSubArray)
        
        labelset()
    }
    
    @IBAction func hobbyCreate() {
        let alertView = UIAlertController(
            title: "Hobbyを追加",
            message: "",
            preferredStyle: .alert)
        var textField: UITextField?
        alertView.addTextField { alertTextField in
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            if let newHobby = textField?.text, !newHobby.isEmpty {
                if let index = self.hobby.firstIndex(of: newHobby) {
                    self.selected = index
                    self.HobbyPickerView.selectRow(index, inComponent: 0, animated: true)
                } else {
                    self.hobby.append(newHobby)
                    self.HobbyPickerView.reloadAllComponents()
                    self.selected = self.hobby.count - 1
                    self.HobbyPickerView.selectRow(self.hobby.count - 1, inComponent: 0, animated: true)
                }
                self.HobbyPickerView.reloadAllComponents()
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alertView.addAction(action)
        alertView.addAction(cancelAction)
        present(alertView, animated: true, completion: nil)
    }


    
    @IBAction func back(_ sender: UIStoryboardSegue) {
            performSegue(withIdentifier: "unwindToMypage", sender: self)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMypage" {
            if let destinationVC = segue.destination as? MypageViewController {
                destinationVC.datas = datas
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }


}
