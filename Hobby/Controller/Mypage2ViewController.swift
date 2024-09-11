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
    @IBOutlet var okButton: UIButton!
    @IBOutlet var newButton: UIButton!
    @IBOutlet weak var miniview: UIView!
    
    var datas : [String] = []
    var buttons : [UIButton] = []
    var labels : [UILabel] = []
    var imageviews: [UIImageView] = []
    
    var selected = 0
    
    var starthobby: [String] = []
    var hobby: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowButton(from: newButton)
        shadowButton(from: okButton)
        getAllTextFields(from: miniview)
        miniview.layer.cornerRadius = 5

        HobbyPickerView.delegate = self
        HobbyPickerView.dataSource = self
        SearchTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        SearchTextfield.delegate = self
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            let label = self.view.viewWithTag(i+3) as! UILabel
            let image = self.view.viewWithTag(i + 6) as! UIImageView
            button.addTarget(self, action: #selector(Mypage2ViewController.tap), for: .touchUpInside)
            button.layer.cornerRadius = 20
            buttons.append(button)
            labels.append(label)
            imageviews.append(image)
        }
        connect()
        
        labelset()
    }
    
    @objc func tap(_ sender:UIButton) {
        datas[sender.tag + 5] = ""
        labelset()
    }
    
    func labelset(){
        let subArray = Array(datas[6...8])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        let emptyStrings = subArray.filter { $0.isEmpty }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        
        if nonEmptyStrings.count > 0{
            backButton.isEnabled = true
        }else{
            backButton.isEnabled = false
        }
        datas.replaceSubrange(6...8, with: sortedSubArray)
        
        for i in 0...2{
            labels[i].text = datas[i+6]
            buttons[i].isHidden = labels[i].text == ""
            imageviews[i].isHidden = labels[i].text == ""
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
    
    @objc func textFieldDidChange(sender: UITextField) {
        if let newHobby = sender.text, !newHobby.isEmpty {
            self.hobby = self.starthobby
            self.hobby = self.hobby.filter { $0.contains(newHobby) }
            if self.hobby.count != 0 {
                self.HobbyPickerView.reloadAllComponents()
                alartLabel.text = ""
            }else{
                self.hobby = self.starthobby
                alartLabel.text = "ないです"
            }
        } else {
            self.hobby = self.starthobby
            self.HobbyPickerView.reloadAllComponents()
            alartLabel.text = ""
        }
    }
    
    @IBAction func hobbySerect(){
        let subArray = Array(datas[6...8])
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
        datas.replaceSubrange(6...8, with: sortedSubArray)
        
        labelset()
    }
    
    @IBAction func hobbyCreate() {
        self.hobby = self.starthobby
        self.HobbyPickerView.reloadAllComponents()
        let alertView = UIAlertController(
            title: "Hobbyを追加",
            message: "※同じ趣味を登録する人が出るまで、すれ違いは起きません",
            preferredStyle: .alert)
        var textField: UITextField?
        alertView.addTextField { alertTextField in
            textField = alertTextField
            textField!.delegate = self
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            if let newHobby = textField?.text, !newHobby.isEmpty {
                if let index = self.hobby.firstIndex(of: newHobby) {
                    self.selected = index
                    self.HobbyPickerView.selectRow(index, inComponent: 0, animated: true)
                } else {
                    self.hobby.append(newHobby)
                    self.starthobby = self.hobby
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
    
    func connect() {
        waitingAnimation(Motherview: self.view)
        fetch(url: "request_hobby") { [weak self] hobbies, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if error != nil {
                    self.neterror()
                    return
                }
                if let hobbies = hobbies as? [[Any]] {
                    if !hobbies.isEmpty {
                        var datas: [(String, Int)] = []
                        for hobby in hobbies {
                            if let hobbyName = hobby[0] as? String, let hobbyCount = hobby[1] as? Int {
                                datas.append((String(hobbyName), hobbyCount))
                            }
                        }
                        datas.sort { $0.1 > $1.1 }
                        
                        self.starthobby = datas.map { $0.0 }
                        self.hobby = self.starthobby
                        self.HobbyPickerView.reloadAllComponents()
                        self.labelset()
                        
                        for _ in 0...3 {
                            let remove = self.view.viewWithTag(100)
                            remove?.removeFromSuperview()
                        }
                    }
                } else {
                    self.neterror()
                }
            }
        }
    }

    func neterror() {
        for _ in 0...3 {
            let remove = self.view.viewWithTag(100)
            remove?.removeFromSuperview()
        }
        
        let alertView = UIAlertController(
            title: "エラー",
            message: "ネットワークエラーです",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) {_ in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        let reaction = UIAlertAction(title: "再読み込み", style: .default) {_ in
            self.connect()
        }
        alertView.addAction(action)
        alertView.addAction(reaction)
        
        self.present(alertView, animated: true, completion: nil)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
