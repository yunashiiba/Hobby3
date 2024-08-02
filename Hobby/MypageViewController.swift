//
//  MypageViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/31.
//

import UIKit
import Foundation

class MypageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    
    @IBOutlet var colorView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var alartLabel: UILabel!
    
    var user_id = 0
    var datas: [String] = []
    
    let countries = ["日本","中国","韓国","アメリカ","アジア","中東","欧州","アフリカ","北米","中南米","大洋州"]
    
    var buttons : [UIButton] = []
    var labels : [UILabel] = []
    
    var pickerrow = ""
    
    let saveData: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        connect()
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            let label = self.view.viewWithTag(i+3) as! UILabel
            button.addTarget(self, action: #selector(MypageViewController.tap), for: .touchUpInside)
            buttons.append(button)
            labels.append(label)
        }
        
    }
    
    @objc func tap(_ sender:UIButton) {
        datas[sender.tag + 4] = ""
        hobbyset()
    }
    
    @IBAction func namechange() {
        let alertView = UIAlertController(
            title: "名前を変更",
            message: "",
            preferredStyle: .alert)
        var textField: UITextField?
        alertView.addTextField { alertTextField in
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { [self] _ in
            if textField?.text != nil && textField?.text != ""{
                datas[0] = (textField?.text)!
                labelset()
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alertView.addAction(action)
        alertView.addAction(cancelAction)
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func agechange(){
        sawalart(int: 2)
    }
    @IBAction func countrychange(){
        sawalart(int: 3)
    }
    
    func sawalart(int: Int){
        let alertView = UIAlertController(
            title: "選んでね",
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert)
     
        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 350, height: 162))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(Int(datas[int])!, inComponent: 0, animated: false)
        pickerrow = datas[int]
        pickerView.tag = 10 + int
        alertView.view.addSubview(pickerView)
     
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [self] _ in
           if pickerrow != ""{
               datas[int] = pickerrow
               labelset()
           }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)

        alertView.addAction(action)
        alertView.addAction(cancelAction)

        present(alertView, animated: true, completion: {
            pickerView.frame.size.width = alertView.view.frame.size.width
        })
    }
    
    func connect(){
        if saveData.object(forKey: "user_id") != nil {
            user_id = saveData.object(forKey: "user_id") as! Int
            if user_id != 0 {
                fetch(url:"request_userdata/\(user_id)") { data, error in
                    if let error = error {
                        print("Failed to fetch user IDs: \(error)")
                        return
                    }
                    if let data = data {
                        self.datas = data as! [String]
                        while self.datas.count < 8 {
                            self.datas.append("")
                        }
                        DispatchQueue.main.async { [self] in
                            labelset()
                            hobbyset()
                        }
                        
                        print("datas: \(self.datas)")
                    } else {
                        print("No user IDs found")
                    }
                }
        }}
    }
    
    func labelset(){
        nameLabel.text = datas[0]
        idLabel.text = datas[1]
        ageLabel.text = "年齢：" + String(datas[2]) + "0代"
        countryLabel.text = "住んでる国：" + countries[Int(datas[3])!]
        colorView.backgroundColor = UIColor(hex: datas[4])
    }
    
    func hobbyset(){
        let subArray = Array(datas[5...])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        let emptyStrings = subArray.filter { $0.isEmpty }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        
        if nonEmptyStrings.count > 0{
            backButton.isEnabled = true
        }else{
            backButton.isEnabled = false
        }
        datas.replaceSubrange(5..., with: sortedSubArray)
        
        for i in 0...2{
            labels[i].text = datas[i+5]
            if labels[i].text != "" {
                buttons[i].isHidden = false
            }else{
                buttons[i].isHidden = true
            }
        }
    }
    
    @IBAction func back() {
        datas.append(String(user_id))
        guard let url = URL(string: "https://6d64-54-238-240-47.ngrok-free.app/request_userchange") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(datas)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard data != nil else {
                print("No data received")
                return
            }
            // 必要に応じてレスポンスのデコード処理をここに追加
            DispatchQueue.main.async {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        task.resume()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to Mypage2" {
            let View2 = segue.destination as! Mypage2ViewController
            View2.datas = datas
        }
    }
    
    @IBAction func unwindToMypage(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? Mypage2ViewController {
            datas = sourceVC.datas
            labelset()
            hobbyset()
        }
    }
    
    @IBAction func logout(){
        saveData.set(0,forKey: "user_id")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 12 {
            return 11
        } else{
            return countries.count
        }
    }
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        if pickerView.tag == 12 {
            return "\(row)0代"
        } else{
            return countries[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        pickerrow = "\(row)"
    }

}
